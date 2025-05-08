#!/bin/bash

# === Thông tin cấu hình ===
ENV_FILE="$HOME/.iproyal.env"
CONTAINER_NAME="iproyal-pawns"
IMAGE_NAME="iproyal/pawns-cli:latest"
SCRIPT_PATH="$HOME/install_iproyal.sh"
RAW_URL="https://chat.openai.com/sandbox/attachments/install_iproyal.sh"

# === Cài đặt hệ thống và tạo container ===
function setup() {
  echo "🔥 Đang chuẩn bị hệ thống để cài đặt IPRoyal Pawns CLI..."
  sleep 1
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER

  echo ""
  read -p "👉 Nhập email IPRoyal của bạn: " EMAIL
  read -sp "🔑 Nhập mật khẩu: " PASSWORD
  echo ""

  DEVICE_NAME=$(hostname)
  DEVICE_ID=$(hostname)

  # Tạo file cấu hình
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

  echo -e "\n✅ Cài đặt xong! Bạn có thể dùng menu để kiểm tra."
}

# === Kiểm tra container có chạy không ===
function check_container() {
  if docker ps | grep -q $CONTAINER_NAME; then
    echo "✅ Container '$CONTAINER_NAME' đang chạy."
  else
    echo "❌ Container '$CONTAINER_NAME' KHÔNG chạy."
  fi
}

# === Xem log container ===
function view_logs() {
  echo "📜 Log hoạt động (Ctrl+C để thoát):"
  docker logs -f $CONTAINER_NAME
}

# === Kiểm tra earning theo log ===
function check_earning_status() {
  echo "💰 Trạng thái earning gần nhất:"
  docker logs $CONTAINER_NAME 2>/dev/null | grep balance_ready | tail -n 5
}

# === Gỡ toàn bộ hệ thống ===
function uninstall_all() {
  echo "🧹 Đang gỡ bỏ toàn bộ..."
  docker stop $CONTAINER_NAME 2>/dev/null
  docker rm $CONTAINER_NAME 2>/dev/null
  rm -f $ENV_FILE
  sudo apt purge -y docker.io
  sudo apt autoremove -y
  echo "✅ Đã xoá toàn bộ hệ thống."
}

# === Cập nhật script menu (không mất dữ liệu) ===
function update_script() {
  echo "⬇️ Đang cập nhật script..."
  wget -q $RAW_URL -O $SCRIPT_PATH && chmod +x $SCRIPT_PATH
  echo "✅ Script đã được cập nhật!"
}

# === Thiết lập alias gọi menu ip-menu nếu chưa có ===
function setup_alias() {
  if ! grep -q "alias ip-menu=" ~/.bashrc; then
    echo "alias ip-menu='bash ~/install_iproyal.sh'" >> ~/.bashrc
    echo "✅ Đã thêm alias 'ip-menu'."
    source ~/.bashrc
  fi
}

# === Menu chính ===
function main_menu() {
  while true; do
    echo -e "\n🎛️ MENU IPRoyal Pawns CLI:"
    echo "1) Kiểm tra container"
    echo "2) Xem log"
    echo "3) Kiểm tra earning"
    echo "4) Cài đặt lại"
    echo "5) Gỡ bỏ toàn bộ"
    echo "6) Cập nhật script"
    echo "0) Thoát"
    read -p "👉 Chọn chức năng: " choice
    case $choice in
      1) check_container ;;
      2) view_logs ;;
      3) check_earning_status ;;
      4) setup ;;
      5) uninstall_all ;;
      6) update_script ;;
      0) echo "👋 Tạm biệt!"; exit 0 ;;
      *) echo "❓ Lựa chọn không hợp lệ!" ;;
    esac
  done
}

# === Bắt đầu ===
setup_alias
main_menu
