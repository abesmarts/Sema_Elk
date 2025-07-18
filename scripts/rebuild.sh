#!/bin/bash
set -e

echo "Rebuilding Semaphore container with OpenTofu" 

docker compose down

docker compose build --no-cache

docker compose up -d

echo "Waiting for services to start..."
sleep 25

echo "verofying OpenTofu installation..."
docker compose exec semaphore tofu version

echo "Reuild complete"