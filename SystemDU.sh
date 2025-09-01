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
NC='\033[0m' # No Color

# --- Text Definitions ---

# English
text_root_check_en="Error: This script must be run as root. Please use sudo."
text_panel_title_en="System_DU Panel"
text_time_en="Time"
text_ip_addr_en="IP Addr"
text_location_en="Location"
text_ipv4_pref_en="IPv4 Preferred"
text_ipv6_pref_en="IPv6 Preferred"
text_sys_config_en="System Configuration"
text_cpu_model_en="CPU Model"
text_cpu_cores_en="CPU Cores"
text_memory_en="Memory"
text_disk_en="Disk (/)"
text_total_en="Total"
text_used_en="Used"
text_swap_en="SWAP"
text_status_en="System Status"
text_os_version_en="OS Version"
text_kernel_version_en="Kernel"
text_net_opt_en="Network Optimization"
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
text_menu_0_en="Exit & Clean Script"
text_prompt_select_en="Please select an option"
text_prompt_continue_en="Press any key to return to the menu..."
text_invalid_option_en="Invalid option. Please try again."
text_exiting_en="Exiting and cleaning up script file..."
# ... (rest of the English text variables remain the same)

# Chinese
text_root_check_zh="错误：此脚本必须以root用户身份运行。请使用 sudo。"
text_panel_title_zh="System_DU 集成面板"
text_time_zh="当前时间"
text_ip_addr_zh="IP 地址"
text_location_zh="IP 归属地"
text_ipv4_pref_zh="IPv4 优先"
text_ipv6_pref_zh="IPv6 优先"
text_sys_config_zh="系统配置"
text_cpu_model_zh="CPU 型号"
text_cpu_cores_zh="CPU 核心"
text_memory_zh="内存"
text_disk_zh="磁盘 (/)"
text_total_zh="总共"
text_used_zh="已用"
text_swap_zh="交换分区"
text_status_zh="系统状态"
text_os_version_zh="系统版本"
text_kernel_version_zh="内核版本"
text_net_opt_zh="网络优化"
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
text_menu_0_zh="退出并清理脚本"
text_prompt_select_zh="请输入选项"
text_prompt_continue_zh="按任意键返回主菜单..."
text_invalid_option_zh="无效选项，请重试。"
text_exiting_zh="正在退出并清理脚本文件..."
# ... (rest of the Chinese text variables remain the same)

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
        primary_ip_for_geo=$ipv4
    else
        ip_priority_status="${BOLD}$(get_text ipv6_pref)${NC}"
        ip_display_order="${ipv6}${ipv4:+ / ${ipv4}}"
        primary_ip_for_geo=$ipv4
    fi

    location=$(curl -s --max-time 3 "http://ip-api.com/json/${primary_ip_for_geo}?fields=country,city" | jq -r 'if .country then .country + ", " + .city else "" end')

    echo -e "${CYAN}=========================== $(get_text panel_title) ===========================${NC}"
    echo -e " ${YELLOW}$(get_text time_en):${NC}    $(date '+%Y-%m-%d %H:%M:%S %A')"
    echo -e " ${YELLOW}$(get_text ip_addr_en):${NC} ${ip_display_order} (${ip_priority_status})"
    [ -n "$location" ] && echo -e " ${YELLOW}$(get_text location_en):${NC} ${location}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
}

display_system_info() {
    cpu_info=$(grep 'model name' /proc/cpuinfo | uniq | awk -F': ' '{print $2}')
    cpu_cores=$(grep -c 'processor' /proc/cpuinfo)
    
    mem_info_line=$(free -h | awk '/^Mem:/ {print $2, $3}')
    total_mem=$(echo "$mem_info_line" | awk '{print $1}')
    used_mem=$(echo "$mem_info_line" | awk '{print $2}')
    mem_display_str="$(get_text total): ${total_mem} / $(get_text used): ${used_mem}"

    swap_info_line=$(free -h | awk '/^Swap:/ {print $2, $3}')
    total_swap=$(echo "$swap_info_line" | awk '{print $1}')
    used_swap=$(echo "$swap_info_line" | awk '{print $2}')
    swap_display_str="$(get_text total): ${total_swap} / $(get_text used): ${used_swap}"

    disk_info_line=$(df -h / | awk 'NR==2 {print $2, $3, $5}')
    total_disk=$(echo "$disk_info_line" | awk '{print $1}')
    used_disk=$(echo "$disk_info_line" | awk '{print $2}')
    percent_disk=$(echo "$disk_info_line" | awk '{print $3}')
    disk_display_str="$(get_text used): ${used_disk} / $(get_text total): ${total_disk} (${percent_disk})"
    
    echo -e "${MAGENTA}${BOLD}$(get_text sys_config):${NC}"
    echo -e " ${YELLOW}$(get_text cpu_model):${NC}  ${cpu_info}"
    echo -e " ${YELLOW}$(get_text cpu_cores):${NC}  ${cpu_cores}"
    echo -e " ${YELLOW}$(get_text memory):${NC}     ${mem_display_str}"
    echo -e " ${YELLOW}$(get_text swap):${NC}     ${swap_display_str}"
    echo -e " ${YELLOW}$(get_text disk):${NC}   ${disk_display_str}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
}

display_status_info() {
    os_version=$(grep "PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    kernel_version=$(uname -r)
    
    # --- FIX START: Display both BBR and FQ status ---
    congestion_algo=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk -F'= ' '{print $2}')
    qdisc_algo=$(sysctl net.core.default_qdisc 2>/dev/null | awk -F'= ' '{print $2}')
    
    if [ "$congestion_algo" == "bbr" ] && [[ "$qdisc_algo" == "fq"* ]]; then
        net_opt_status="${GREEN}${congestion_algo} + ${qdisc_algo}${NC}"
    else
        net_opt_status="${RED}${congestion_algo} + ${qdisc_algo}${NC}"
    fi
    # --- FIX END ---

    echo -e "${MAGENTA}${BOLD}$(get_text status_en):${NC}"
    echo -e " ${YELLOW}$(get_text os_version_en):${NC} ${os_version}"
    echo -e " ${YELLOW}$(get_text kernel_version_en):${NC}  ${kernel_version}"
    echo -e " ${YELLOW}$(get_text net_opt_en):${NC}       ${net_opt_status}"
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
    display_status_info
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
            0) 
                echo "$(get_text exiting)"
                # Self-cleaning command
                rm -- "$0"
                exit 0 
                ;;
            *) echo -e "${RED}$(get_text invalid_option)${NC}" ;;
        esac
        
        if [ "$needs_pause" = true ]; then
            echo ""
            read -n 1 -s -r -p "$(get_text prompt_continue)"
        fi
    done
}

main
