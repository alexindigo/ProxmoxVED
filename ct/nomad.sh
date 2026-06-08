#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Alex Indigo (alexindigo)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Crosstalk-Solutions/project-nomad | https://www.projectnomad.us

APP="Nomad"
var_tags="${var_tags:-offline;knowledge;education;ai}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_gpu="${var_gpu:-yes}"
var_nesting="${var_nesting:-1}"
var_keyctl="${var_keyctl:-1}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/nomad ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "nomad" "Crosstalk-Solutions/project-nomad"; then
    msg_info "Stopping Service"
    cd /opt/nomad
    $STD docker compose down
    msg_ok "Stopped Service"

    fetch_and_deploy_gh_release "nomad" "Crosstalk-Solutions/project-nomad" "tarball"

    msg_info "Updating ${APP}"
    $STD docker compose pull
    msg_ok "Updated ${APP}"

    msg_info "Starting Service"
    $STD docker compose up -d
    msg_ok "Started Service"
    msg_ok "Updated Successfully"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"
