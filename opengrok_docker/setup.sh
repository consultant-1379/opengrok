#!/bin/sh
#FOR LOCAL DEV ONLY
DOCKER_BUILD_SETTINGS=$1
DOCKER_UP_SETTINGS=$2
# Please make sure you have given this setup script executable rights
# Creating appropriate directories for each project area
mkdir -p eic/src_eic_docker eic/etc_eic_docker eic/data_eic_docker
mkdir -p enm/src_enm_docker enm/etc_enm_docker enm/data_enm_docker
mkdir -p ci/src_ci_docker ci/etc_ci_docker ci/data_ci_docker
mkdir -p cENM/data_cENM_docker cENM/etc_cENM_docker

# Assign permissions to scripts
chmod -R +x scripts
./scripts/clone_repos.sh eic
./scripts/clone_repos.sh enm
./scripts/clone_repos.sh ci

# Docker commands
docker-compose down
docker-compose build $DOCKER_BUILD_SETTINGS #--no-cache
docker-compose up $DOCKER_UP_SETTINGS #--force-recreate