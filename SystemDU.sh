#!/bin/bash

# --- Script State ---
CURRENT_LANG="en" # Default language: "en" for English, "zh" for Chinese

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;95m'
BOLD='\033[1m'
NC='\033[0m'

# --- Text Definitions ---

# English
text_root_check_en="Error: This script must be run as root. Please use sudo."
text_panel_title_en="System_DU Panel"
text_time_en="Time"
text_ip_addr_en="IP Addr"
text_ipv4_pref_en="IPv4 Preferred"
text_ipv6_pref_en="IPv6 Preferred"
text_sys_config_en="System Configuration"
text_cpu_model_en="CPU Model"
text_cpu_cores_en="CPU Cores"
text_memory_en="Memory"
text_disk_en="Disk (/)"
text_total_en="Total"
text_used_en="Used"
text_swap_en="Swap"
text_menu_title_en="--- New System Auto-Configuration ---"
text_menu_1_en="One-Click Automated Setup (Update & Dependencies)"
text_menu_2_en="Configure BBR + FQ"
text_menu_3_en="Restore Original Network Settings (Remove BBR)"
text_menu_4_en="Create SWAP File"
text_menu_5_en="Delete SWAP File"
text_menu_6_en="Change Hostname"
text_menu_7_en="Disable IPv6 (Reboot required)"
text_menu_8_en="Enable IPv6 (Reboot required)"
text_menu_9_en="Prefer IPv4"
text_menu_10_en="Prefer IPv6"
text_menu_11_en="Switch to Chinese (切换到中文)"
text_menu_0_en="Exit"
text_prompt_select_en="Please select an option"
text_prompt_continue_en="Press any key to return to the menu..."
text_invalid_option_en="Invalid option. Please try again."
text_exiting_en="Exiting."
text_auto_config_start_en="--- Starting Automated System Configuration ---"
text_auto_config_update_en="Updating and upgrading system packages..."
text_auto_config_deps_en="Installing essential dependencies..."
text_auto_config_grub_en="Updating GRUB..."
text_auto_config_done_en="--- Automated Configuration Complete! ---"
text_bbr_backup_en="Original sysctl.conf backed up to /etc/sysctl.conf.bak_bbr"
text_bbr_enable_en="Enabling BBR + FQ..."
text_bbr_verify_en="Verifying BBR status..."
text_bbr_success_en="BBR + FQ has been successfully enabled."
text_bbr_fail_en="Failed to enable BBR. Kernel version 4.9+ is required."
text_bbr_restore_en="Restoring original sysctl configuration..."
text_bbr_restore_success_en="Original sysctl configuration has been restored."
text_bbr_restore_fail_en="No backup file found. Cannot restore."
text_swap_exists_en="A SWAP file or partition already exists."
text_swap_prompt_size_en="Enter SWAP size in Megabytes (e.g., 1024 for 1GB):"
text_swap_invalid_input_en="Invalid input. Please enter a number."
text_swap_creating_en="Creating a %sMB SWAP file at /swapfile..."
text_swap_success_en="SWAP file created and enabled successfully."
text_swap_delete_fail_en="No /swapfile found to delete."
text_swap_deleting_en="Disabling and deleting /swapfile..."
text_swap_delete_success_en="SWAP file has been deleted."
text_hostname_current_en="Current hostname is"
text_hostname_prompt_new_en="Enter the new hostname:"
text_hostname_empty_en="Hostname cannot be empty."
text_hostname_setting_en="Setting new hostname to '%s'..."
text_hostname_success_en="Hostname has been permanently changed to '%s'."
text_hostname_note_en="Note: The change will be fully visible after a new login session."
text_ipv6_disable_en="Disabling IPv6..."
text_ipv6_disable_success_en="IPv6 has been disabled via sysctl."
text_ipv6_enable_en="Enabling IPv6..."
text_ipv6_enable_success_en="IPv6 has been enabled via sysctl."
text_reboot_prompt_en="To ensure the change is fully applied, a system reboot is recommended."
text_reboot_confirm_en="Do you want to reboot now? (y/n):"
text_reboot_now_en="Rebooting now..."
text_reboot_cancel_en="Reboot cancelled. Please reboot manually later."
text_ipv4_set_pref_en="Setting IPv4 as preferred..."
text_ipv4_set_pref_success_en="IPv4 is now preferred. Changes take effect immediately for new connections."
text_ipv6_set_pref_en="Setting IPv6 as preferred..."
text_ipv6_set_pref_success_en="IPv6 is now preferred. Changes take effect immediately for new connections."

# Chinese
text_root_check_zh="错误：此脚本必须以root用户身份运行。请使用 sudo。"
text_panel_title_zh="System_DU 集成面板"
text_time_zh="当前时间"
text_ip_addr_zh="IP 地址"
text_ipv4_pref_zh="IPv4 优先"
text_ipv6_pref_zh="IPv6 优先"
text_sys_config_zh="系统配置"
text_cpu_model_zh="CPU 型号"
text_cpu_cores_zh="CPU 核心"
text_memory_zh="内存"
text_disk_zh="磁盘 (/)"
text_total_zh="总共"
text_used_zh="已用"
text_swap_zh="交换"
text_menu_title_zh="--- 新系统自动化配置 ---"
text_menu_1_zh="一键自动化配置 (更新系统与依赖)"
text_menu_2_zh="配置 BBR + FQ"
text_menu_3_zh="还原网络设置 (移除 BBR)"
text_menu_4_zh="创建 SWAP 交换文件"
text_menu_5_zh="删除 SWAP 交换文件"
text_menu_6_zh="更改主机名"
text_menu_7_zh="禁用 IPv6 (需要重启)"
text_menu_8_zh="启用 IPv6 (需要重启)"
text_menu_9_zh="设置为 IPv4 优先"
text_menu_10_zh="设置为 IPv6 优先"
text_menu_11_zh="Switch to English (切换到英文)"
text_menu_0_zh="退出"
text_prompt_select_zh="请输入选项"
text_prompt_continue_zh="按任意键返回主菜单..."
text_invalid_option_zh="无效选项，请重试。"
text_exiting_zh="正在退出。"
text_auto_config_start_zh="--- 开始自动化系统配置 ---"
text_auto_config_update_zh="正在更新和升级系统软件包..."
text_auto_config_deps_zh="正在安装核心依赖..."
text_auto_config_grub_zh="正在更新 GRUB..."
text_auto_config_done_zh="--- 自动化配置完成！---"
text_bbr_backup_zh="已备份原始 sysctl.conf 文件至 /etc/sysctl.conf.bak_bbr"
text_bbr_enable_zh="正在启用 BBR + FQ..."
text_bbr_verify_zh="正在验证 BBR 状态..."
text_bbr_success_zh="BBR + FQ 已成功启用。"
text_bbr_fail_zh="BBR 启用失败。需要 4.9 或更高版本的内核。"
text_bbr_restore_zh="正在还原原始 sysctl 配置..."
text_bbr_restore_success_zh="原始 sysctl 配置已还原。"
text_bbr_restore_fail_zh="未找到备份文件，无法还原。"
text_swap_exists_zh="系统中已存在 SWAP 文件或分区。"
text_swap_prompt_size_zh="请输入 SWAP 文件大小 (单位 MB, 例如: 1024 代表 1GB):"
text_swap_invalid_input_zh="输入无效，请输入一个数字。"
text_swap_creating_zh="正在创建 %sMB 大小的 SWAP 文件于 /swapfile..."
text_swap_success_zh="SWAP 文件已成功创建并启用。"
text_swap_delete_fail_zh="未找到 /swapfile 文件，无法删除。"
text_swap_deleting_zh="正在禁用并删除 /swapfile..."
text_swap_delete_success_zh="SWAP 文件已被删除。"
text_hostname_current_zh="当前主机名是"
text_hostname_prompt_new_zh="请输入新的主机名:"
text_hostname_empty_zh="主机名不能为空。"
text_hostname_setting_zh="正在设置新主机名为 '%s'..."
text_hostname_success_zh="主机名已永久更改为 '%s'。"
text_hostname_note_zh="注意：更改将在新的登录会话中完全生效。"
text_ipv6_disable_zh="正在禁用 IPv6..."
text_ipv6_disable_success_zh="已通过 sysctl 禁用 IPv6。"
text_ipv6_enable_zh="正在启用 IPv6..."
text_ipv6_enable_success_zh="已通过 sysctl 启用 IPv6。"
text_reboot_prompt_zh="为确保更改完全应用，建议重启系统。"
text_reboot_confirm_zh="您想现在重启吗? (y/n):"
text_reboot_now_zh="正在立即重启..."
text_reboot_cancel_zh="已取消重启。请稍后手动重启。"
text_ipv4_set_pref_zh="正在设置为 IPv4 优先..."
text_ipv4_set_pref_success_zh="已设置为 IPv4 优先。更改对新连接立即生效。"
text_ipv6_set_pref_zh="正在设置为 IPv6 优先..."
text_ipv6_set_pref_success_zh="已设置为 IPv6 优先。更改对新连接立即生效。"

# --- Language Function ---
get_text() {
    local var_name="text_${1}_${CURRENT_LANG}"
    echo -n "${!var_name}"
}

toggle_language() {
    if [ "$CURRENT_LANG" == "en" ]; then
        CURRENT_LANG="zh"
    else
        CURRENT_LANG="en"
    fi
}

# --- Function to check for root privileges ---
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}$(get_text root_check)${NC}"
        exit 1
    fi
}

# --- Header Display Functions ---
display_header() {
    ipv4=$(hostname -I | awk '{print $1}')
    ipv6=$(curl -s6 --max-time 3 https://ifconfig.co || hostname -I | awk '{for(i=1;i<=NF;i++) if($i ~ /:/) {print $i; exit}}')
    
    if grep -q -E '^\s*precedence ::ffff:0:0/96\s+100' /etc/gai.conf 2>/dev/null; then
        ip_priority_status="${BOLD}$(get_text ipv4_pref)${NC}"
        ip_display_order="${ipv4}${ipv6:+ / ${ipv6}}"
    else
        ip_priority_status="${BOLD}$(get_text ipv6_pref)${NC}"
        ip_display_order="${ipv6}${ipv4:+ / ${ipv4}}"
    fi

    echo -e "${CYAN}=========================== $(get_text panel_title) ===========================${NC}"
    echo -e " ${YELLOW}$(get_text time_zh):${NC}    $(date '+%Y-%m-%d %H:%M:%S %A')"
    echo -e " ${YELLOW}$(get_text ip_addr_zh):${NC} ${ip_display_order} (${ip_priority_status})"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
}

display_system_info() {
    cpu_info=$(grep 'model name' /proc/cpuinfo | uniq | awk -F': ' '{print $2}')
    cpu_cores=$(grep -c 'processor' /proc/cpuinfo)
    total_mem=$(free -h | awk '/^Mem:/ {print $2}')
    current_usage=$(free -h | awk --source '{printf "Used: %s / Swap: %s", $3, $7}' | sed "s/Used/$(get_text used)/g" | sed "s/Swap/$(get_text swap)/g")
    disk_usage=$(df -h / | awk --source 'NR==2 {printf "Used: %s / Total: %s (%s)", $3, $2, $5}' | sed "s/Used/$(get_text used)/g" | sed "s/Total/$(get_text total)/g")

    echo -e "${MAGENTA}${BOLD}$(get_text sys_config):${NC}"
    echo -e " ${YELLOW}$(get_text cpu_model):${NC}  ${cpu_info}"
    echo -e " ${YELLOW}$(get_text cpu_cores):${NC}  ${cpu_cores}"
    echo -e " ${YELLOW}$(get_text memory):${NC}     $(get_text total): ${total_mem} | ${current_usage}"
    echo -e " ${YELLOW}$(get_text disk):${NC}   ${disk_usage}"
    echo -e "${CYAN}=======================================================================${NC}"
}

# --- Core Functions ---
auto_config_system() {
    echo -e "${CYAN}$(get_text auto_config_start)${NC}"
    [[ "$CURRENT_LANG" == "zh" ]] && echo "# 此功能将更新您的系统并安装常用工具。"
    echo -e "${YELLOW}$(get_text auto_config_update)${NC}"
    apt-get -y update && apt-get -y upgrade
    echo -e "${YELLOW}$(get_text auto_config_deps)${NC}"
    apt-get install -y curl wget socat cron sudo jq
    echo -e "${YELLOW}$(get_text auto_config_grub)${NC}"
    update-grub
    echo -e "${GREEN}$(get_text auto_config_done)${NC}"
}

config_bbr() {
    [[ "$CURRENT_LANG" == "zh" ]] && echo "# 此功能通过启用BBR+FQ算法来优化网络拥塞控制，提升网速。"
    if [ ! -f /etc/sysctl.conf.bak_bbr ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak_bbr
        echo -e "${GREEN}$(get_text bbr_backup)${NC}"
    fi
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo -e "${YELLOW}$(get_text bbr_enable)${NC}"
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1
    echo -e "${CYAN}$(get_text bbr_verify)${NC}"
    if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
        echo -e "${GREEN}$(get_text bbr_success)${NC}"
    else
        echo -e "${RED}$(get_text bbr_fail)${NC}"
    fi
}

restore_bbr() {
    if [ -f /etc/sysctl.conf.bak_bbr ]; then
        echo -e "${YELLOW}$(get_text bbr_restore)${NC}"
        mv /etc/sysctl.conf.bak_bbr /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1
        echo -e "${GREEN}$(get_text bbr_restore_success)${NC}"
    else
        echo -e "${RED}$(get_text bbr_restore_fail)${NC}"
    fi
}

config_swap() {
    [[ "$CURRENT_LANG" == "zh" ]] && echo "# SWAP（交换文件）可以在物理内存不足时，将部分硬盘空间当作内存使用。"
    if [ "$(swapon --show | wc -l)" -gt 0 ]; then
        echo -e "${YELLOW}$(get_text swap_exists)${NC}"
        return
    fi
    read -p "$(get_text swap_prompt_size) " swap_size
    if ! [[ "$swap_size" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(get_text swap_invalid_input)${NC}"
        return
    fi
    printf -v msg "$(get_text swap_creating)" "$swap_size"
    echo -e "${YELLOW}${msg}${NC}"
    fallocate -l "${swap_size}M" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo -e "${GREEN}$(get_text swap_success)${NC}"
}

delete_swap() {
    if [ ! -f /swapfile ]; then
        echo -e "${RED}$(get_text swap_delete_fail)${NC}"
        return
    fi
    echo -e "${YELLOW}$(get_text swap_deleting)${NC}"
    swapoff /swapfile
    rm /swapfile
    sed -i '/\/swapfile/d' /etc/fstab
    echo -e "${GREEN}$(get_text swap_delete_success)${NC}"
}

config_hostname() {
    local current_hostname=$(hostname)
    read -p "$(get_text hostname_current) '$current_hostname'. $(get_text hostname_prompt_new) " new_hostname
    if [ -z "$new_hostname" ]; then
        echo -e "${RED}$(get_text hostname_empty)${NC}"
        return
    fi
    printf -v msg "$(get_text hostname_setting)" "$new_hostname"
    echo -e "${YELLOW}${msg}${NC}"
    hostnamectl set-hostname "$new_hostname"
    sed -i "s/127.0.1.1.*$current_hostname/127.0.1.1\t$new_hostname/g" /etc/hosts
    printf -v msg "$(get_text hostname_success)" "$new_hostname"
    echo -e "${GREEN}${msg}${NC}"
    echo -e "${YELLOW}$(get_text hostname_note)${NC}"
}

manage_ipv6() {
    local action=$1
    local sysctl_conf="/etc/sysctl.conf"
    local message=""

    if [ "$action" == "disable" ]; then
        echo -e "${YELLOW}$(get_text ipv6_disable)${NC}"
        sed -i '/net.ipv6.conf.all.disable_ipv6/d' $sysctl_conf
        sed -i '/net.ipv6.conf.default.disable_ipv6/d' $sysctl_conf
        echo "net.ipv6.conf.all.disable_ipv6 = 1" >> $sysctl_conf
        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> $sysctl_conf
        sysctl -p >/dev/null 2>&1
        message="${GREEN}$(get_text ipv6_disable_success)${NC}"
    elif [ "$action" == "enable" ]; then
        echo -e "${YELLOW}$(get_text ipv6_enable)${NC}"
        sed -i '/net.ipv6.conf.all.disable_ipv6/d' $sysctl_conf
        sed -i '/net.ipv6.conf.default.disable_ipv6/d' $sysctl_conf
        echo "net.ipv6.conf.all.disable_ipv6 = 0" >> $sysctl_conf
        echo "net.ipv6.conf.default.disable_ipv6 = 0" >> $sysctl_conf
        sysctl -p >/dev/null 2>&1
        message="${GREEN}$(get_text ipv6_enable_success)${NC}"
    fi

    echo -e "$message"
    echo -e "${YELLOW}$(get_text reboot_prompt)${NC}"
    read -p "$(get_text reboot_confirm) " reboot_choice
    if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
        echo -e "${RED}$(get_text reboot_now)${NC}"
        sleep 2
        reboot
    else
        echo -e "${CYAN}$(get_text reboot_cancel)${NC}"
    fi
}

set_ip_priority() {
    local priority=$1
    local gai_conf="/etc/gai.conf"
    
    touch $gai_conf
    sed -i '/^precedence ::ffff:0:0\/96/d' $gai_conf

    if [ "$priority" == "ipv4" ]; then
        echo -e "${YELLOW}$(get_text ipv4_set_pref)${NC}"
        echo "precedence ::ffff:0:0/96  100" >> $gai_conf
        echo -e "${GREEN}$(get_text ipv4_set_pref_success)${NC}"
    elif [ "$priority" == "ipv6" ]; then
        echo -e "${YELLOW}$(get_text ipv6_set_pref)${NC}"
        echo -e "${GREEN}$(get_text ipv6_set_pref_success)${NC}"
    fi
}

# --- Main Menu ---
show_menu() {
    clear
    display_header
    display_system_info
    echo -e "${BOLD}$(get_text menu_title)${NC}"
    echo " 1. $(get_text menu_1)"
    echo " 2. $(get_text menu_2)"
    echo " 3. $(get_text menu_3)"
    echo " 4. $(get_text menu_4)"
    echo " 5. $(get_text menu_5)"
    echo " 6. $(get_text menu_6)"
    echo " 7. $(get_text menu_7)"
    echo " 8. $(get_text menu_8)"
    echo " 9. $(get_text menu_9)"
    echo " 10. $(get_text menu_10)"
    echo " 11. $(get_text menu_11)"
    echo ""
    echo " 0. $(get_text menu_0)"
    echo -e "${CYAN}=======================================================================${NC}"
}

# --- Main Loop ---
main() {
    check_root
    while true; do
        show_menu
        read -p "$(get_text prompt_select) [0-11]: " choice
        local needs_pause=true
        case $choice in
            1) auto_config_system ;;
            2) config_bbr ;;
            3) restore_bbr ;;
            4) config_swap ;;
            5) delete_swap ;;
            6) config_hostname ;;
            7) manage_ipv6 "disable"; needs_pause=false ;;
            8) manage_ipv6 "enable"; needs_pause=false ;;
            9) set_ip_priority "ipv4" ;;
            10) set_ip_priority "ipv6" ;;
            11) toggle_language; needs_pause=false ;;
            0) echo "$(get_text exiting)"; exit 0 ;;
            *) echo -e "${RED}$(get_text invalid_option)${NC}" ;;
        esac
        
        if [ "$needs_pause" = true ]; then
            echo ""
            read -n 1 -s -r -p "$(get_text prompt_continue)"
        fi
    done
}

main
