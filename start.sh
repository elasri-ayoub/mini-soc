#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/6] Configuration du système (vm.max_map_count) ==="
CURRENT_MAP=$(sysctl -n vm.max_map_count)
if [ "$CURRENT_MAP" -lt 262144 ]; then
    sudo sysctl -w vm.max_map_count=262144
fi

echo "=== [2/6] Vérification du réseau Docker 'soc-net' ==="
if ! docker network ls | grep -q "soc-net"; then
    docker network create soc-net
fi

echo "=== [3/6] Préparation des répertoires et permissions ==="
mkdir -p "$PROJECT_DIR/shuffle/shuffle-db" "$PROJECT_DIR/shuffle/shuffle-files" "$PROJECT_DIR/shuffle/shuffle-apps"
mkdir -p "$PROJECT_DIR/thehive/cassandra_data" "$PROJECT_DIR/thehive/es_data" "$PROJECT_DIR/thehive/thehive_data" "$PROJECT_DIR/thehive/thehive_index" "$PROJECT_DIR/thehive/cortex_data"
sudo chmod -R 777 "$PROJECT_DIR/shuffle/shuffle-db" "$PROJECT_DIR/shuffle/shuffle-files"
sudo chmod -R 777 "$PROJECT_DIR/thehive/es_data" "$PROJECT_DIR/thehive/cassandra_data" "$PROJECT_DIR/thehive/thehive_data" "$PROJECT_DIR/thehive/cortex_data"

if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo "=== [4/6] Démarrage de Wazuh ==="
cd "$PROJECT_DIR/wazuh-docker/single-node"
if [ ! -f "config/wazuh_indexer_ssl_certs/root-ca.pem" ]; then
    $DOCKER_COMPOSE -f generate-indexer-certs.yml run --rm generator
fi
$DOCKER_COMPOSE up -d

echo "=== [5/6] Démarrage de TheHive, Cortex et Shuffle ==="
cd "$PROJECT_DIR/thehive" && $DOCKER_COMPOSE up -d
cd "$PROJECT_DIR/shuffle" && $DOCKER_COMPOSE up -d

echo "=== [6/6] Démarrage du banc d'essai (Attaquant / Cible) ==="
cd "$PROJECT_DIR/lab-simulation" && $DOCKER_COMPOSE up -d --build

echo "=== Déploiement terminé avec succès ! ==="
