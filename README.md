# HedgeDoc Deployment Environment

## How to Use this Repository

1. Clone this repository
2. Update environment variables in `.env` with appropriate values. Most importantly the following, because by this repository
defaults to login only via GitHub:
   1. CMD_GITHUB_CLIENTID
   2. CMD_GITHUB_CLIENTSECRET
   3. CMD_DOMAIN
3. Run the script with the desired operation 

## The Script

Yes, I know, it's janky, but I didn't want to enforce Python as a dependency, so I wrote it in Bash. It's not that bad, I promise.

### Usage

```bash
./hedge.sh [operation]
```

- `init` - Initialize the environment. Grabs the latest version of HedgeDoc, then builds and runs the containers.
- `update` - Update the environment. Grabs the latest version of HedgeDoc.
- `start` - Start the environment. Starts the containers.
- `stop` - Stop the environment. Stops the containers.
