#!/usb/bin/env bash
set -e

pwd
ls

log() {
  echo ">> [local]" $@
}

cleanup() {
  set +e
  log "Killing ssh agent."
  ssh-agent -k
}
trap cleanup EXIT

log "Launching ssh agent."
eval `ssh-agent -s`

REPO_NAME=${GITHUB_REPOSITORY}
GITHUB_TOKEN=${GITHUB_TOKEN}

# For test only
# GITHUB_TOKEN="-----BEGIN OPENSSH PRIVATE KEY-----b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZWQyNTUxOQAAACBboEvlsJF5xSnfDEKn2GkR5Rc+gfzRcEfxx37VAqURkAAAAJgvBnPxLwZz8QAAAAtzc2gtZWQyNTUxOQAAACBboEvlsJF5xSnfDEKn2GkR5Rc+gfzRcEfxx37VAqURkAAAAED6jeG2DvS4vZGHKQGdSozpwwIEjSJB1T5clMmUmdoXmlugS+WwkXnFKd8MQqfYaRHlFz6B/NFwR/HHftUCpRGQAAAADm5la29AYXJjaGxpbnV4AQIDBAUGBw==-----END OPENSSH PRIVATE KEY-----" #for test
# REPO_NAME="Axiks/Lumi"
FOLDER_NAME="${REPO_NAME##*/}"

# echo $FOLDER_NAME

GITHUB_TOKEN_ENCODE=$(python3 tokenEncode.py "$GITHUB_TOKEN")

git_url="https://oauth2:${GITHUB_TOKEN_ENCODE}@github.com/${REPO_NAME}.git"


remote_command="set -e ; "
remote_command+="log() { echo '>> [remote]' \$@ ; } ; "
remote_command+="if [ -d "${FOLDER_NAME}" ] ; then "
remote_command+=" cd \"\$HOME/${FOLDER_NAME}\" ; "
remote_command+=" log 'Pull repository...' ; "
remote_command+=" git pull $git_url ; "
remote_command+="else "
remote_command+=" log 'Clone repository...' ; "
remote_command+=" git clone -b make-aspire $git_url ; "
remote_command+=" cd \"\$HOME/${FOLDER_NAME}\" ; "
remote_command+="fi ; "
remote_command+="cp \$HOME/lumi-config/.env .env ; "
remote_command+="cp \$HOME/lumi-config/appsettings.Docker-Production.json Vanilla.Common/appsettings.Docker-Production.json ; "
remote_command+="docker compose stop ; "
remote_command+="log 'Launching docker compose...' ; "
remote_command+="docker compose up -f \"$DOCKER_COMPOSE_FILENAME\" -p \"$DOCKER_COMPOSE_PREFIX\" --remove-orphans --build --force-recreate ; "

# echo "$remote_command" >foo.sh

ssh-add <(echo "$SSH_PRIVATE_KEY")

echo ">> [local] Connecting to remote host."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
 "$SSH_USER@$SSH_HOST" -p "$SSH_PORT" \
 "$remote_command"
