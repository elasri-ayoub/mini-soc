#!/bin/bash
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo "Arrêt de Shuffle..."
cd shuffle && $DOCKER_COMPOSE down && cd ..

echo "Arrêt de TheHive & Cortex..."
cd thehive && $DOCKER_COMPOSE down && cd ..

echo "Arrêt de Wazuh..."
cd wazuh-docker/single-node && $DOCKER_COMPOSE down && cd ..

echo "Toutes les stacks du Mini-SOC sont arrêtées."
