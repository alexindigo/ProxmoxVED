#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Alex Indigo (alexindigo)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Crosstalk-Solutions/project-nomad | https://www.projectnomad.us

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

USE_DOCKER_REPO=true setup_docker
setup_hwaccel

NOMAD_DATA_DIR="${NOMAD_DATA_DIR:-/opt/nomad}"

fetch_and_deploy_gh_release "nomad" "Crosstalk-Solutions/project-nomad" "tarball"

msg_info "Configuring Nomad"
mkdir -p ${NOMAD_DATA_DIR}/{storage/logs,mysql,redis}
curl -fsSL "https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/refs/heads/main/install/management_compose.yaml" -o /opt/nomad/compose.yml
curl -fsSL "https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/refs/heads/main/install/start_nomad.sh" -o /opt/nomad/start_nomad.sh
curl -fsSL "https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/refs/heads/main/install/stop_nomad.sh" -o /opt/nomad/stop_nomad.sh
curl -fsSL "https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/refs/heads/main/install/update_nomad.sh" -o /opt/nomad/update_nomad.sh
chmod +x /opt/nomad/*.sh

sed -i "s|/opt/project-nomad|${NOMAD_DATA_DIR}|g" /opt/nomad/compose.yml

APP_KEY=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c32)
DB_ROOT_PASSWORD=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c13)
DB_USER_PASSWORD=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c13)

sed -i "s|URL=replaceme|URL=http://${LOCAL_IP}|g" /opt/nomad/compose.yml
sed -i "s|APP_KEY=replaceme|APP_KEY=${APP_KEY}|g" /opt/nomad/compose.yml
sed -i "s|DB_PASSWORD=replaceme|DB_PASSWORD=${DB_USER_PASSWORD}|g" /opt/nomad/compose.yml
sed -i "s|MYSQL_ROOT_PASSWORD=replaceme|MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}|g" /opt/nomad/compose.yml
sed -i "s|MYSQL_PASSWORD=replaceme|MYSQL_PASSWORD=${DB_USER_PASSWORD}|g" /opt/nomad/compose.yml
sed -i 's|"8080:8080"|"80:8080"|g' /opt/nomad/compose.yml
msg_ok "Configured Nomad"

msg_info "Starting Nomad"
cd /opt/nomad
$STD docker compose up -d
msg_ok "Started Nomad"

motd_ssh
customize
cleanup_lxc
