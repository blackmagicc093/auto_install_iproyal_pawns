#!/bin/bash

ENV_FILE=".env"
CONTAINER_NAME="iproyal-pawns"
IMAGE_NAME="iproyal/pawns-cli:latest"

function setup() {
  echo "🔥 Preparing system for IPRoyal Pawns CLI setup..."
  sleep 1
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER
  read -p "👉 Enter your IPRoyal email: " EMAIL
  read -sp "🔑 Enter your IPRoyal password: " PASSWORD
  echo ""
  DEVICE_NAME=$(hostname)
  DEVICE_ID=$(hostname)
  cat <<EOF > $ENV_FILE
EMAIL=$EMAIL
PASSWORD=$PASSWORD
DEVICE_NAME=$DEVICE_NAME
DEVICE_ID=$DEVICE_ID
EOF
  docker pull $IMAGE_NAME
  docker stop $CONTAINER_NAME 2>/dev/null
  docker rm $CONTAINER_NAME 2>/dev/null
  docker run -d \
    --name $CONTAINER_NAME \
    --restart=always \
    --env-file $ENV_FILE \
    $IMAGE_NAME \
    -email=$EMAIL \
    -password=$PASSWORD \
    -device-name=$DEVICE_NAME \
    -device-id=$DEVICE_ID \
    -accept-tos
  echo -e "\n✅ Setup complete. Use menu to manage the container."
}

function check_container() {
  if docker ps | grep -q $CONTAINER_NAME; then
    echo "✅ Container '$CONTAINER_NAME' is running."
  else
    echo "❌ Container '$CONTAINER_NAME' is not running."
  fi
}

function view_logs() {
  echo "📜 Showing logs (Press Ctrl+C to stop):"
  docker logs -f $CONTAINER_NAME
}

function check_earning_status() {
  echo "🔍 Checking earning status (Look for 'balance_ready' in logs):"
  docker logs $CONTAINER_NAME 2>/dev/null | grep balance_ready | tail -n 5
}

function reinstall_all() {
  echo "⚙️ Reinstalling..."
  setup
}

function uninstall_all() {
  echo "🧹 Removing everything..."
  docker stop $CONTAINER_NAME 2>/dev/null
  docker rm $CONTAINER_NAME 2>/dev/null
  rm -f $ENV_FILE
  sudo apt purge -y docker.io
  sudo apt autoremove -y
  echo "✅ Everything removed. System is clean."
}

while true; do
  echo -e "\n🎛️ IPRoyal Pawns CLI Menu:"
  echo "1) Check if container is running"
  echo "2) View logs"
  echo "3) Check earning status"
  echo "4) Reinstall everything"
  echo "5) Uninstall and clean system"
  echo "0) Exit"
  read -p "Choose an option: " choice
  case $choice in
    1) check_container ;;
    2) view_logs ;;
    3) check_earning_status ;;
    4) reinstall_all ;;
    5) uninstall_all ;;
    0) echo "👋 Goodbye!"; exit 0 ;;
    *) echo "❓ Invalid option!" ;;
  esac
done
