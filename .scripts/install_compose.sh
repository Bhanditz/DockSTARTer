#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

install_compose() {
    # https://docs.docker.com/compose/install/ OR https://github.com/javabean/arm-compose
    local AVAILABLE_COMPOSE
    AVAILABLE_COMPOSE=$(curl -H "${GH_HEADER:-}" -s "https://api.github.com/repos/docker/compose/releases/latest" | grep -Po '"tag_name": "[Vv]?\K.*?(?=")') || fatal "Failed to check latest available docker-compose version."
    local INSTALLED_COMPOSE
    INSTALLED_COMPOSE=$( (docker-compose --version 2> /dev/null || true) | sed -E 's/.* version ([^,]*)(, build .*)?/\1/')
    local FORCE
    FORCE=${1:-}
    if [[ ${AVAILABLE_COMPOSE} != "${INSTALLED_COMPOSE}" ]] || [[ -n ${FORCE} ]]; then
        info "Installing latest docker-compose."
#
        # add if statements (if these exist)
        rm /usr/local/bin/docker-compose > /dev/null 2>&1 || fatal "Failed to remove /usr/local/bin/docker-compose binary."
        rm /usr/bin/docker-compose > /dev/null 2>&1 || fatal "Failed to remove /usr/bin/docker-compose binary."

        # this seems to be the most supported way to install across all systems
        pip install -U pip > /dev/null 2>&1 || fatal "Failed to install latest pip."
        pip uninstall docker-py > /dev/null 2>&1 || true
        pip install -U setuptools > /dev/null 2>&1 || fatal "Failed to install latest dependencies from pip."
        pip install -U docker-compose > /dev/null 2>&1 || fatal "Failed to install docker-compose from pip."
#
        local UPDATED_COMPOSE
        UPDATED_COMPOSE=$( (docker-compose --version 2> /dev/null || true) | sed -E 's/.* version ([^,]*)(, build .*)?/\1/')
        if [[ ${AVAILABLE_COMPOSE} != "${UPDATED_COMPOSE}" ]]; then
            fatal "Failed to install the latest docker-compose."
        fi
    fi
}
