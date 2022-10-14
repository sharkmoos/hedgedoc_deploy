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
  latest=$(curl -s -L https://hedgedoc.org/latest-release | grep -Eo 'URL=https://hedgedoc.org/releases/[0-9]+\.[0-9]+\.[0-9]+')
  version=$(echo $latest | cut -d"/" -f5)
  echo "Latest HedgeDoc version is $version"
}


create_ctf_base_page()
{
  echo "[-] Switching HedgeDoc back to manual login mode"
  sed -i "/CMD_EMAIL=false/c\#CMD_EMAIL=false" .env
  docker-compose -p hedgedoc up -d
  sleep 5

  echo "[-] Creating CTF base page"
  docker cp first_note.md.jinja hedgedoc_app_1:/tmp
  docker cp ctfd-api-automation.py hedgedoc_app_1:/tmp
  docker-compose -p hedgedoc exec app /bin/bash -c "hedgedoc login --email admin@user.com foobar"
  docker-compose -p hedgedoc exec app /bin/bash -c "cd /tmp && python3 /tmp/ctfd-api-automation.py"
  output=$(docker-compose -p hedgedoc exec app /bin/bash -c "hedgedoc import /tmp/first_note.md | tail -n 1")
  echo "[-] CTF base page created with URL: $output"

  # reload hedgedoc. Nobody else should be able to create an account via username and password.
  echo "[-] Switching HedgeDoc back to GitHub Login mode"
  sed -i "/#CMD_EMAIL=false/c\CMD_EMAIL=false" .env
  docker-compose -p hedgedoc up -d
}

check_docker_tools

if [ "$1" = "init" ]; then
  get_version_number
  update_version_environment  "$version"
  docker-compose -p hedgedoc up -d
  echo "[-] Waiting for services to start..."
  sleep 10

  docker-compose -p hedgedoc exec app /bin/bash -c 'curl -X POST "$HEDGEDOC_SERVER/register" --data "email=admin@user.com&password=foobar"'
  docker-compose -p hedgedoc exec app /bin/bash -c "hedgedoc login --email admin@user.com foobar"

  create_ctf_base_page

fi

if [ "$1" = "create_note" ]; then
  create_ctf_base_page
fi

if [ "$1" = "update" ]; then
  get_version_number
  update_version_environment  "$version"
fi

if [ "$1" = "start" ]; then
  docker-compose -p hedgedoc up -d
fi

if [ "$1" = "stop" ]; then
  docker-compose stop
fi

if [ "$1" = "destroy" ]; then
  docker-compose down
  docker volume rm hedgedoc_database
  docker volume rm hedgedoc_uploads
fi
