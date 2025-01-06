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

FOLDER_NAME="${REPO_NAME##*/}"
FOLDER_NAME="${FOLDER_NAME}-${REPO_NAME}"

GITHUB_TOKEN_ENCODE=$(python3 /tokenEncode.py "$GITHUB_TOKEN")

git_url="https://oauth2:${GITHUB_TOKEN_ENCODE}@github.com/${REPO_NAME}.git"
git_branch_name= $GITHUB_BRANCH_NAME #"make-aspire"

env_file_name= $ENV_FILE_NAME #".env"
path_to_env_file="\$HOME/lumi-config/$env_file_name"


remote_command="set -e ; "
remote_command+="log() { echo '>> [remote]' \$@ ; } ; "
remote_command+="if [ -d "${FOLDER_NAME}" ] ; then "
remote_command+=" cd \"\$HOME/${FOLDER_NAME}\" ; "
remote_command+=" log 'Pull repository...' ; "
remote_command+=" sleep 30 ; "
remote_command+=" git pull $git_url ; "
remote_command+=" git pull ; "
remote_command+="else "
remote_command+=" log 'Clone repository...' ; "
remote_command+=" git clone -b $git_branch_name $git_url ; "
remote_command+=" cd \"\$HOME/${FOLDER_NAME}\" ; "
remote_command+="fi ; "
remote_command+="cp $path_to_env_file $env_file_name ; "
remote_command+="docker compose stop ; "
remote_command+="log 'Launching docker compose...' ; "
remote_command+="docker compose -f \"$DOCKER_COMPOSE_FILENAME\" -p \"$DOCKER_COMPOSE_PREFIX\" --env-file $env_file_name up --remove-orphans --build --force-recreate ; "

# echo "$remote_command" >foo.sh

ssh-add <(echo "$SSH_PRIVATE_KEY")

echo ">> [local] Connecting to remote host."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
 "$SSH_USER@$SSH_HOST" -p "$SSH_PORT" \
 "$remote_command"
