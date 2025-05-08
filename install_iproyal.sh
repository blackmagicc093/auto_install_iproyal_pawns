#!/bin/bash

# === CẤU HÌNH HỆ THỐNG ===
ENV_FILE="$HOME/.iproyal.env"
CONTAINER_NAME="iproyal-pawns"
IMAGE_NAME="iproyal/pawns-cli:latest"
SCRIPT_PATH="$HOME/install_iproyal.sh"
RAW_URL="https://chat.openai.com/sandbox/attachments/install_iproyal.sh"

# === MÀU SẮC ===
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# === CÀI ĐẶT MỚI TOÀN BỘ ===
function setup() {
  echo -e "${YELLOW}🚀 Đang cài đặt IPRoyal Pawns CLI...${RESET}"
  sleep 1
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER

  echo ""
  read -p "📧 Nhập email IPRoyal: " EMAIL
  read -sp "🔑 Nhập mật khẩu: " PASSWORD
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

  echo -e "${GREEN}✅ Đã cài đặt thành công!${RESET}"
}

# === KIỂM TRA CONTAINER ===
function check_container() {
  if docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${GREEN}✅ Container đang chạy.${RESET}"
  else
    echo -e "${RED}❌ Container KHÔNG chạy.${RESET}"
  fi
}

# === XEM LOG ===
function view_logs() {
  echo -e "${BLUE}📜 Hiển thị log (nhấn Ctrl+C để thoát)...${RESET}"
  docker logs -f $CONTAINER_NAME
}

# === KIỂM TRA EARNING ===
function check_earning_status() {
  echo -e "${BLUE}💰 Kiểm tra trạng thái earning:${RESET}"
  docker logs $CONTAINER_NAME 2>/dev/null | grep balance_ready | tail -n 5
}

# === GỠ TOÀN BỘ HỆ THỐNG ===
function uninstall_all() {
  echo -e "${YELLOW}🧹 Đang gỡ toàn bộ hệ thống...${RESET}"
  docker stop $CONTAINER_NAME 2>/dev/null
  docker rm $CONTAINER_NAME 2>/dev/null
  rm -f $ENV_FILE
  sudo apt purge -y docker.io
  sudo apt autoremove -y
  echo -e "${GREEN}✅ Đã gỡ bỏ hoàn toàn.${RESET}"
}

# === CẬP NHẬT SCRIPT ===
function update_script() {
  echo -e "${BLUE}⬇️ Đang cập nhật script...${RESET}"
  wget -q $RAW_URL -O $SCRIPT_PATH && chmod +x $SCRIPT_PATH
  echo -e "${GREEN}✅ Script đã được cập nhật!${RESET}"
}

# === KHỞI ĐỘNG LẠI CONTAINER ===
function restart_container() {
  echo -e "${YELLOW}🔁 Đang khởi động lại container...${RESET}"
  docker restart $CONTAINER_NAME
  echo -e "${GREEN}✅ Container đã được khởi động lại.${RESET}"
}

# === KHỞI ĐỘNG LẠI DỊCH VỤ DOCKER ===
function restart_docker() {
  echo -e "${YELLOW}🔄 Đang khởi động lại Docker daemon...${RESET}"
  sudo systemctl restart docker
  echo -e "${GREEN}✅ Docker đã được khởi động lại.${RESET}"
}

# === THÊM ALIAS ip-menu (NẾU CHƯA CÓ) ===
function setup_alias() {
  if ! grep -q "alias ip-menu=" ~/.bashrc; then
    echo "alias ip-menu='bash ~/install_iproyal.sh'" >> ~/.bashrc
    echo -e "${GREEN}✅ Đã thêm lệnh tắt 'ip-menu'.${RESET}"
    source ~/.bashrc
  fi
}

# === MENU GIAO DIỆN ===
function main_menu() {
  while true; do
    echo -e "\\n${BLUE}🎛️ MENU IPRoyal Pawns CLI${RESET}"
    echo "1) Kiểm tra container đang chạy"
    echo "2) Xem log hoạt động"
    echo "3) Kiểm tra earning"
    echo "4) Cài đặt lại toàn bộ"
    echo "5) Gỡ toàn bộ hệ thống"
    echo "6) Cập nhật script"
    echo "7) Khởi động lại container"
    echo "8) Khởi động lại Docker"
    echo "0) Thoát"
    read -p "👉 Nhập lựa chọn: " choice
    case $choice in
      1) check_container ;;
      2) view_logs ;;
      3) check_earning_status ;;
      4) setup ;;
      5) uninstall_all ;;
      6) update_script ;;
      7) restart_container ;;
      8) restart_docker ;;
      0) echo -e "${YELLOW}👋 Tạm biệt!${RESET}"; exit 0 ;;
      *) echo -e "${RED}⚠️ Lựa chọn không hợp lệ!${RESET}" ;;
    esac
  done
}

# === CHẠY CHƯƠNG TRÌNH ===
setup_alias
main_menu
