#!/bin/bash

# === MÀU SẮC ===
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# === TÊN FILE VÀ ĐƯỜNG DẪN ===
SCRIPT_PATH="$HOME/install_iproyal.sh"
ALIAS_CMD="alias ip-menu='bash $SCRIPT_PATH'"

# === TẢI FILE SCRIPT CHÍNH VỀ ĐÚNG VỊ TRÍ ===
echo -e "${YELLOW}⬇️ Đang tải script cài đặt về...${RESET}"
wget -q https://chat.openai.com/sandbox/attachments/install_iproyal.sh -O $SCRIPT_PATH
chmod +x $SCRIPT_PATH

# === THÊM ALIAS ip-menu VÀO ~/.bashrc (nếu chưa có) ===
if ! grep -q "alias ip-menu=" ~/.bashrc; then
  echo "$ALIAS_CMD" >> ~/.bashrc
  echo -e "${GREEN}✅ Đã thêm alias 'ip-menu' vào ~/.bashrc${RESET}"
else
  echo -e "${YELLOW}ℹ️ Alias 'ip-menu' đã tồn tại trong ~/.bashrc${RESET}"
fi

# === LOAD LẠI ~/.bashrc ĐỂ KÍCH HOẠT ALIAS ===
echo -e "${BLUE}🔁 Đang tải lại ~/.bashrc...${RESET}"
source ~/.bashrc

# === CHẠY SCRIPT MENU NGAY ===
echo -e "${GREEN}🚀 Khởi động menu IPRoyal...${RESET}"
bash $SCRIPT_PATH
