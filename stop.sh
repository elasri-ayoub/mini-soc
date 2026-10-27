#!/bin/bash
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo "Arrêt de la simulation (Attaquant / Cible)..."
cd "$PROJECT_DIR/lab-simulation" && $DOCKER_COMPOSE down 2>/dev/null || true

echo "Arrêt de Shuffle..."
cd "$PROJECT_DIR/shuffle" && $DOCKER_COMPOSE down 2>/dev/null || true

echo "Arrêt de TheHive & Cortex..."
cd "$PROJECT_DIR/thehive" && $DOCKER_COMPOSE down 2>/dev/null || true

echo "Arrêt de Wazuh..."
cd "$PROJECT_DIR/wazuh-docker/single-node" && $DOCKER_COMPOSE down 2>/dev/null || true

echo "Toutes les stacks du Mini-SOC sont arrêtées."
