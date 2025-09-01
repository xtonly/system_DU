#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;95m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Function to check for root privileges ---
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run as root. Please use sudo.${NC}"
        exit 1
    fi
}

# --- Header Display Functions ---
display_header() {
    # Get IP addresses
    ipv4=$(hostname -I | awk '{print $1}')
    ipv6=$(curl -s6 --max-time 3 https://ifconfig.co || hostname -I | awk '{for(i=1;i<=NF;i++) if($i ~ /:/) {print $i; exit}}')
    
    # Check IP priority from /etc/gai.conf
    if ! grep -q -E '^precedence ::ffff:0:0/96' /etc/gai.conf || \
       (grep -q -E '^precedence ::ffff:0:0/96  100' /etc/gai.conf && \
        (! grep -q -E '^label 2002::/16' /etc/gai.conf || grep -q -E '^#label 2002::/16' /etc/gai.conf)); then
        ip_priority_status="${BOLD}IPv4 Preferred${NC}"
        ip_display_order="${ipv4}${ipv6:+ / ${ipv6}}"
    else
        ip_priority_status="${BOLD}IPv6 Preferred${NC}"
        ip_display_order="${ipv6}${ipv4:+ / ${ipv4}}"
    fi

    # Display Header
    echo -e "${CYAN}=========================== System_DU Panel ===========================${NC}"
    echo -e " ${YELLOW}Time:${NC}    $(date '+%Y-%m-%d %H:%M:%S %A')"
    echo -e " ${YELLOW}IP Addr:${NC} ${ip_display_order} (${ip_priority_status})"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
}

display_system_info() {
    cpu_info=$(grep 'model name' /proc/cpuinfo | uniq | awk -F': ' '{print $2}')
    cpu_cores=$(grep -c 'processor' /proc/cpuinfo)
    total_mem=$(free -h | awk '/^Mem:/ {print $2}')
    current_usage=$(free -h | awk '/^Mem:/ {printf "Used: %s / Swap: %s", $3, $7}')
    disk_usage=$(df -h / | awk 'NR==2 {printf "Used: %s / Total: %s (%s)", $3, $2, $5}')
    
    echo -e "${MAGENTA}${BOLD}System Configuration:${NC}"
    echo -e " ${YELLOW}CPU Model:${NC}  ${cpu_info}"
    echo -e " ${YELLOW}CPU Cores:${NC}  ${cpu_cores}"
    echo -e " ${YELLOW}Memory:${NC}     Total: ${total_mem} | ${current_usage}"
    echo -e " ${YELLOW}Disk (/):${NC}   ${disk_usage}"
    echo -e "${CYAN}=======================================================================${NC}"
}

# --- 1. Automated System Configuration ---
auto_config_system() {
    echo -e "${CYAN}--- Starting Automated System Configuration ---${NC}"
    echo -e "${YELLOW}Updating and upgrading system packages...${NC}"
    apt-get -y update && apt-get -y upgrade
    echo -e "${YELLOW}Installing essential dependencies...${NC}"
    apt-get install -y curl wget socat cron sudo jq
    echo -e "${YELLOW}Updating GRUB...${NC}"
    update-grub
    echo -e "${GREEN}--- Automated Configuration Complete! ---${NC}"
}

# --- 2. BBR + FQ Configuration ---
config_bbr() {
    if [ ! -f /etc/sysctl.conf.bak_bbr ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak_bbr
        echo -e "${GREEN}Original sysctl.conf backed up to /etc/sysctl.conf.bak_bbr${NC}"
    fi
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo -e "${YELLOW}Enabling BBR + FQ...${NC}"
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    echo -e "${CYAN}Verifying BBR status...${NC}"
    if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
        echo -e "${GREEN}BBR + FQ has been successfully enabled.${NC}"
    else
        echo -e "${RED}Failed to enable BBR. Kernel version 4.9+ is required.${NC}"
    fi
}

restore_bbr() {
    if [ -f /etc/sysctl.conf.bak_bbr ]; then
        echo -e "${YELLOW}Restoring original sysctl configuration...${NC}"
        mv /etc/sysctl.conf.bak_bbr /etc/sysctl.conf
        sysctl -p
        echo -e "${GREEN}Original sysctl configuration has been restored.${NC}"
    else
        echo -e "${RED}No backup file found. Cannot restore.${NC}"
    fi
}

# --- 3. SWAP Configuration ---
config_swap() {
    if [ "$(swapon --show | wc -l)" -gt 0 ]; then
        echo -e "${YELLOW}A SWAP file or partition already exists.${NC}"
        return
    fi
    read -p "Enter SWAP size in Megabytes (e.g., 1024 for 1GB): " swap_size
    if ! [[ "$swap_size" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input. Please enter a number.${NC}"
        return
    fi
    echo -e "${YELLOW}Creating a ${swap_size}MB SWAP file at /swapfile...${NC}"
    fallocate -l "${swap_size}M" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo -e "${GREEN}SWAP file created and enabled successfully.${NC}"
}

delete_swap() {
    if [ ! -f /swapfile ]; then
        echo -e "${RED}No /swapfile found to delete.${NC}"
        return
    fi
    echo -e "${YELLOW}Disabling and deleting /swapfile...${NC}"
    swapoff /swapfile
    rm /swapfile
    sed -i '/\/swapfile/d' /etc/fstab
    echo -e "${GREEN}SWAP file has been deleted.${NC}"
}

# --- 4. Hostname Configuration ---
config_hostname() {
    local current_hostname=$(hostname)
    read -p "Current hostname is '$current_hostname'. Enter the new hostname: " new_hostname
    if [ -z "$new_hostname" ]; then
        echo -e "${RED}Hostname cannot be empty.${NC}"
        return
    fi
    echo -e "${YELLOW}Setting new hostname to '$new_hostname'...${NC}"
    hostnamectl set-hostname "$new_hostname"
    sed -i "s/127.0.1.1.*$current_hostname/127.0.1.1\t$new_hostname/g" /etc/hosts
    echo -e "${GREEN}Hostname has been permanently changed to '$new_hostname'.${NC}"
    echo -e "${YELLOW}Note: The change will be fully visible after a new login session.${NC}"
}

# --- 5. IPv6 Management ---
manage_ipv6() {
    local action=$1
    local sysctl_conf="/etc/sysctl.conf"
    local grub_conf="/etc/default/grub"

    if [ "$action" == "disable" ]; then
        echo -e "${YELLOW}Disabling IPv6...${NC}"
        sed -i '/net.ipv6.conf.all.disable_ipv6/d' $sysctl_conf
        sed -i '/net.ipv6.conf.default.disable_ipv6/d' $sysctl_conf
        echo "net.ipv6.conf.all.disable_ipv6 = 1" >> $sysctl_conf
        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> $sysctl_conf
        sysctl -p
        echo -e "${GREEN}IPv6 has been disabled via sysctl. A reboot is recommended.${NC}"
    elif [ "$action" == "enable" ]; then
        echo -e "${YELLOW}Enabling IPv6...${NC}"
        sed -i '/net.ipv6.conf.all.disable_ipv6/d' $sysctl_conf
        sed -i '/net.ipv6.conf.default.disable_ipv6/d' $sysctl_conf
        echo "net.ipv6.conf.all.disable_ipv6 = 0" >> $sysctl_conf
        echo "net.ipv6.conf.default.disable_ipv6 = 0" >> $sysctl_conf
        sysctl -p
        echo -e "${GREEN}IPv6 has been enabled via sysctl. A reboot is recommended.${NC}"
    fi
}

# --- 6. IP Priority Configuration ---
set_ip_priority() {
    local priority=$1
    local gai_conf="/etc/gai.conf"
    
    # Remove existing precedence lines to avoid duplicates
    sed -i '/^precedence ::ffff:0:0\/96/d' $gai_conf

    if [ "$priority" == "ipv4" ]; then
        echo -e "${YELLOW}Setting IPv4 as preferred...${NC}"
        # This is the default behavior on many systems, but we make it explicit.
        # Uncommenting the precedence line makes IPv4 preferred.
        echo "precedence ::ffff:0:0/96  100" >> $gai_conf
        echo -e "${GREEN}IPv4 is now preferred. Changes take effect immediately for new connections.${NC}"
    elif [ "$priority" == "ipv6" ]; then
        echo -e "${YELLOW}Setting IPv6 as preferred...${NC}"
        # Commenting out the precedence line makes the system prefer IPv6.
        # The line is removed above, so no action is needed.
        echo -e "${GREEN}IPv6 is now preferred. Changes take effect immediately for new connections.${NC}"
    fi
}

# --- Main Menu ---
show_menu() {
    clear
    display_header
    display_system_info
    echo -e "${BOLD}--- New System Auto-Configuration ---${NC}"
    echo " 1. One-Click Automated Setup (Update & Dependencies)"
    echo " 2. Configure BBR + FQ"
    echo " 3. Restore Original Network Settings (Remove BBR)"
    echo " 4. Create SWAP File"
    echo " 5. Delete SWAP File"
    echo " 6. Change Hostname"
    echo " 7. Disable IPv6"
    echo " 8. Enable IPv6"
    echo " 9. Prefer IPv4"
    echo " 10. Prefer IPv6"
    echo ""
    echo " 0. Exit"
    echo -e "${CYAN}=======================================================================${NC}"
}

# --- Main Loop ---
main() {
    check_root
    while true; do
        show_menu
        read -p "Please select an option [0-10]: " choice
        case $choice in
            1) auto_config_system ;;
            2) config_bbr ;;
            3) restore_bbr ;;
            4) config_swap ;;
            5) delete_swap ;;
            6) config_hostname ;;
            7) manage_ipv6 "disable" ;;
            8) manage_ipv6 "enable" ;;
            9) set_ip_priority "ipv4" ;;
            10) set_ip_priority "ipv6" ;;
            0) echo "Exiting."; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
        echo ""
        read -n 1 -s -r -p "Press any key to return to the menu..."
    done
}

main
