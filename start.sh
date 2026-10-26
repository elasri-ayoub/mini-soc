#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}         DEPLOIEMENT DU MINI-SOC AUTOMATISE         ${NC}"
echo -e "${BLUE}   Wazuh (SIEM) + Shuffle (SOAR) + TheHive + Cortex ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Vérification des prérequis et des privilèges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Ce script doit être exécuté avec sudo ou en root.${NC}"
  echo -e "    Usage: sudo ./start.sh"
  exit 1
fi

command -v docker >/dev/null 2>&1 || { echo -e "${RED}[!] Docker n'est pas installé. Annulation.${NC}"; exit 1; }
command -v docker compose >/dev/null 2>&1 || command -v docker-compose >/dev/null 2>&1 || { echo -e "${RED}[!] docker compose n'est pas installé. Annulation.${NC}"; exit 1; }

# Alias docker-compose
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# 2. Ajustement des limites du noyau (obligatoire pour Elasticsearch / Wazuh Indexer)
echo -e "\n${YELLOW}[1/6] Configuration des paramètres système (vm.max_map_count)...${NC}"
CURRENT_MAP=$(sysctl -n vm.max_map_count)
if [ "$CURRENT_MAP" -lt 262144 ]; then
    sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
fi
echo -e "${GREEN}[+] vm.max_map_count vérifié (${CURRENT_MAP:-262144})${NC}"

# 3. Création du réseau Docker commun
echo -e "\n${YELLOW}[2/6] Vérification du réseau Docker 'soc-net'...${NC}"
if ! docker network ls | grep -q "soc-net"; then
    docker network create --driver bridge soc-net
    echo -e "${GREEN}[+] Réseau Docker 'soc-net' créé.${NC}"
else
    echo -e "${GREEN}[+] Réseau Docker 'soc-net' déjà existant.${NC}"
fi

# 4. Préparation des répertoires de données et permissions
echo -e "\n${YELLOW}[3/6] Préparation des répertoires de données locaux...${NC}"
mkdir -p shuffle/shuffle-db shuffle/shuffle-files shuffle/shuffle-apps
mkdir -p thehive/cassandra_data thehive/es_data thehive/thehive_data thehive/thehive_index thehive/cortex_data

# Permissions Elasticsearch (UID 1000) et OpenSearch/Shuffle
chmod -R 777 shuffle/shuffle-db shuffle/shuffle-files
chmod -R 777 thehive/es_data thehive/cassandra_data thehive/thehive_data thehive/cortex_data
echo -e "${GREEN}[+] Droits et répertoires configurés.${NC}"

# 5. Démarrage de Wazuh (SIEM)
echo -e "\n${YELLOW}[4/6] Démarrage du SIEM Wazuh...${NC}"
cd wazuh-docker/single-node
# Génération des certificats Wazuh Indexer si absents
if [ ! -f "config/wazuh_indexer_ssl_certs/root-ca.pem" ]; then
    echo -e "${YELLOW}[*] Génération des certificats SSL Wazuh...${NC}"
    $DOCKER_COMPOSE -f generate-indexer-certs.yml run --rm generator
fi
$DOCKER_COMPOSE up -d
cd ../..
echo -e "${GREEN}[+] Stack Wazuh démarrée.${NC}"

# 6. Démarrage de TheHive & Cortex
echo -e "\n${YELLOW}[5/6] Démarrage de TheHive 4 et Cortex...${NC}"
cd thehive
$DOCKER_COMPOSE up -d
cd ..
echo -e "${GREEN}[+] Stack TheHive & Cortex démarrée.${NC}"

# 7. Démarrage de Shuffle (SOAR)
echo -e "\n${YELLOW}[6/6] Démarrage du SOAR Shuffle...${NC}"
cd shuffle
$DOCKER_COMPOSE up -d
cd ..
echo -e "${GREEN}[+] Stack Shuffle démarrée.${NC}"

# 8. Affichage du récapitulatif
HOST_IP=$(hostname -I | awk '{print $1}')
echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}   LE MINI-SOC EST OPERATIONNEL AVEC SUCCES !       ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "Dashboard Wazuh       : https://${HOST_IP}:443 (ou https://localhost:443)"
echo -e "TheHive 4             : http://${HOST_IP}:9000 (ou http://localhost:9000)"
echo -e "Cortex                : http://${HOST_IP}:9001 (ou http://localhost:9001)"
echo -e "Shuffle (SOAR)        : http://${HOST_IP}:3001 (ou http://localhost:3001)"
echo -e "Webhook Shuffle URL   : http://${HOST_IP}:3001/api/v1/hooks/webhook_..."
echo -e "====================================================\n"
