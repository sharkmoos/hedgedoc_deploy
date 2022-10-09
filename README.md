# HedgeDoc Deployment Environment

Note: Currently only supported for Debian based systems

## How to Use this Repository

1. Update your system
2. Clone this repository
3. Update environment variables in `.env` with appropriate values. Most importantly the following, because by this repository
defaults to log in only via GitHub:
   1. CMD_GITHUB_CLIENTID
   2. CMD_GITHUB_CLIENTSECRET
   3. CMD_DOMAIN
4. Set environment variable `SERVER_IP` to the IP address of the server hedgedoc will run on 
   5. eg. `export SERVER_IP=127.0.0.1`
5. Run the script with the desired operation 

## Important Variable to Set

The following variables should be updated in the `.env` file for every new CTF.

```dotenv
CTFD_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXX # Personal access token for the CTFd of the CTF
CTFD_HOST=https://ctf.example.com/ # Base URL of the CTFd instance
CTF_NAME='ComSec CTF' # then name of the CTF
CTF_TEAM_NAME='R0073R5' # Team name to be competing with
CTF_CAPTAIN='ComSec' # the username / handle of the team captain
CTF_START_TIME="Sun, Sept 30, 2022 00:00 AM" # the start time of the CTF
CTF_END_TIME="Sun, Sept 30, 2022 00:00 AM" # the end time of the CTF

CMD_GITHUB_CLIENTID=XXXXXXXXXXXXXXXXXXXX # GitHub OAuth App Client ID
CMD_GITHUB_CLIENTSECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # GitHub OAuth App Client Secret
```

## The Script

Yes, I know, it's janky; I didn't want to enforce Python as a dependency, so I wrote it in Bash. It's not that bad, I promise.

### Usage

```bash
./hedge.sh [operation]
```

- `init` - Initialize the environment. Grabs the latest version of HedgeDoc, then builds and runs the containers.
- `update` - Update the environment. Grabs the latest version of HedgeDoc.
- `start` - Start the environment. Starts the containers.
- `stop` - Stop the environment. Stops the containers.
