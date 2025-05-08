#!/bin/bash

echo "🔥 Preparing system for IPRoyal Pawns CLI setup..."
sleep 1

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker $USER

# Read user input
read -p "👉 Enter your IPRoyal email: " EMAIL
read -sp "🔑 Enter your IPRoyal password: " PASSWORD
echo ""

# Default device name/id from hostname
DEVICE_NAME=$(hostname)
DEVICE_ID=$(hostname)

# Create .env file
cat <<EOF > .env
EMAIL=$EMAIL
PASSWORD=$PASSWORD
DEVICE_NAME=$DEVICE_NAME
DEVICE_ID=$DEVICE_ID
EOF

# Pull the latest image
docker pull iproyal/pawns-cli:latest

# Stop and remove existing container (if any)
docker stop iproyal-pawns 2>/dev/null
docker rm iproyal-pawns 2>/dev/null

# Run container
docker run -d \
  --name iproyal-pawns \
  --restart=always \
  --env-file .env \
  iproyal/pawns-cli:latest \
  -email=$EMAIL \
  -password=$PASSWORD \
  -device-name=$DEVICE_NAME \
  -device-id=$DEVICE_ID \
  -accept-tos

# Output results
echo -e "\n✅ Done! You can check the container with: docker ps"
echo "📜 View logs: docker logs -f iproyal-pawns"
echo "🚀 Your device is now earning passively via IPRoyal!"

# Suggest logout/login if needed
echo -e "\n⚠️ Please logout/login or reboot if Docker group changes don't take effect."
