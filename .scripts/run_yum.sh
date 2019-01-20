#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

run_yum() {
    # https://docs.docker.com/install/linux/docker-ce/centos/
    info "Removing old Docker packages."
    yum -y remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-compose \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-selinux \
        docker-engine-selinux \
        docker-engine > /dev/null 2>&1 || true
    if [[ ${CI:-} != true ]] && [[ ${TRAVIS:-} != true ]]; then
        info "Upgrading packages."
        yum -y install epel-release > /dev/null 2>&1 || fatal "Failed to install dependencies from yum."
        yum -y upgrade > /dev/null 2>&1 || fatal "Failed to upgrade packages from yum."
    fi
    info "Installing dependencies."
    yum -y install curl git grep newt python-pip rsync sed > /dev/null 2>&1 || fatal "Failed to install dependencies from yum."
    info "Removing unused packages."
    yum -y autoremove > /dev/null 2>&1 || fatal "Failed to remove unused packages from yum."
    info "Cleaning up package cache."
    yum -y clean all > /dev/null 2>&1 || fatal "Failed to cleanup cache from yum."
}
