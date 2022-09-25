#!/usr/bin/env bash
# hedgedoc.sh - HedgeDoc server management script

check_uid() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        return 0
    fi
    return 1
}

check_docker_tools()
{
    if ! command -v docker &>/dev/null; then
        echo "Docker is not installed."
        read -r -p "Install Docker? [y/N] " response
        if [ "$response" = "y" ]; then
            if check_uid; then
                echo "Cannot install docker as non-root user. Install manually or rerun this script with superuser privileges."
                exit 1
            fi
            apt install docker.io -qy
        else

            echo "Cannot proceed without docker. Exiting"
            exit 1
        fi
    fi
    if ! command -v docker-compose &>/dev/null; then
        echo "Docker Compose is not installed."
        read -r -p "Install Docker Compose? [y/N] " response
        if [ "$response" = "y" ]; then
            if check_uid; then
                echo "Cannot install docker as non-root user. Install manually or rerun this script with superuser privileges."
                exit 1
            fi
            apt install docker-compose -qy
        else
            echo "Cannot proceed without docker-compose. Exiting"
            exit 1
        fi
    fi
}

update_version_environment()
{
  sed -i "/HEDGEDOC_VERSION=/c\HEDGEDOC_VERSION=$version" .env
}

get_version_number()
{
  latest=$(curl -L https://hedgedoc.org/latest-release | grep -Eo 'URL=https://hedgedoc.org/releases/[0-9]+\.[0-9]+\.[0-9]+')
  version=$(echo $latest | cut -d"/" -f5)
}

check_docker_tools

if [ "$1" = "init" ]; then
  get_version_number
  update_version_environment  "$version"
  docker-compose up -d
fi

if [ "$1" = "update" ]; then
  get_version_number
  update_version_environment  "$version"
fi

if [ "$1" = "start" ]; then
  docker-compose up -d
fi

if [ "$1" = "stop" ]; then
  docker-compose down
fi