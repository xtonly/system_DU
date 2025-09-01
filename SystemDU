
#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Function to check for root privileges ---
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run as root. Please use sudo.${NC}"
        exit 1
    fi
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
    # Backup original sysctl settings
    if [ ! -f /etc/sysctl.conf.bak ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
        echo -e "${GREEN}Original sysctl.conf backed up to /etc/sysctl.conf.bak${NC}"
    fi

    # Remove any existing BBR settings to prevent duplicates
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf

    # Add BBR + FQ settings
    echo -e "${YELLOW}Enabling BBR + FQ...${NC}"
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    
    # Apply the settings
    sysctl -p
    
    # Verify the settings
    echo -e "${CYAN}Verifying BBR status...${NC}"
    local bbr_status=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
    if [ "$bbr_status" == "bbr" ]; then
        echo -e "${GREEN}BBR + FQ has been successfully enabled.${NC}"
    else
        echo -e "${RED}Failed to enable BBR. Please check your kernel version (requires 4.9+).${NC}"
    fi
}

# --- Function to restore original BBR settings ---
restore_bbr() {
    if [ -f /etc/sysctl.conf.bak ]; then
        echo -e "${YELLOW}Restoring original sysctl configuration...${NC}"
        mv /etc/sysctl.conf.bak /etc/sysctl.conf
        sysctl -p
        echo -e "${GREEN}Original sysctl configuration has been restored.${NC}"
    else
        echo -e "${RED}No backup file found. Cannot restore.${NC}"
    fi
}

# --- 3. SWAP Configuration ---
config_swap() {
    # Check if swap already exists
    if [ "$(swapon --show | wc -l)" -gt 0 ]; then
        echo -e "${YELLOW}A SWAP file or partition already exists.${NC}"
        return
    fi

    read -p "Enter the size for the SWAP file in Megabytes (e.g., 1024 for 1GB): " swap_size
    if ! [[ "$swap_size" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input. Please enter a number.${NC}"
        return
    fi
    
    echo -e "${YELLOW}Creating a ${swap_size}MB SWAP file at /swapfile...${NC}"
    fallocate -l "${swap_size}M" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # Make SWAP permanent
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    
    echo -e "${GREEN}SWAP file created and enabled successfully.${NC}"
    free -h
}

# --- Function to delete SWAP ---
delete_swap() {
    if [ ! -f /swapfile ]; then
        echo -e "${RED}No /swapfile found to delete.${NC}"
        return
    fi

    echo -e "${YELLOW}Disabling and deleting /swapfile...${NC}"
    swapoff /swapfile
    rm /swapfile
    
    # Remove from fstab
    sed -i '/\/swapfile/d' /etc/fstab
    
    echo -e "${GREEN}SWAP file has been deleted.${NC}"
    free -h
}

# --- 4. Hostname Configuration ---
config_hostname() {
    local current_hostname=$(hostname)
    echo "Current hostname is: $current_hostname"
    read -p "Enter the new hostname: " new_hostname

    if [ -z "$new_hostname" ]; then
        echo -e "${RED}Hostname cannot be empty.${NC}"
        return
    fi
    
    echo -e "${YELLOW}Setting new hostname to '$new_hostname'...${NC}"
    
    # Change hostname
    hostnamectl set-hostname "$new_hostname"
    
    # Update /etc/hosts to reflect the change
    sed -i "s/127.0.1.1.*$current_hostname/127.0.1.1\t$new_hostname/g" /etc/hosts
    
    echo -e "${GREEN}Hostname has been permanently changed to '$new_hostname'.${NC}"
    echo -e "${YELLOW}Note: The change will be fully visible in your terminal after a new login session.${NC}"
}

# --- Main Menu ---
show_menu() {
    clear
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${CYAN}   Debian/Ubuntu New System Auto-Setup   ${NC}"
    echo -e "${CYAN}===========================================${NC}"
    echo "1. One-Click Automated Configuration (Update & Install Dependencies)"
    echo ""
    echo "--- Network & Performance ---"
    echo "2. Configure BBR + FQ"
    echo "3. Restore Original Network Settings (Remove BBR)"
    echo ""
    echo "--- System Utilities ---"
    echo "4. Create SWAP File"
    echo "5. Delete SWAP File"
    echo "6. Change Hostname"
    echo ""
    echo "0. Exit"
    echo -e "${CYAN}===========================================${NC}"
}

# --- Main Loop ---
main() {
    check_root
    while true; do
        show_menu
        read -p "Please select an option [0-6]: " choice
        case $choice in
            1)
                auto_config_system
                ;;
            2)
                config_bbr
                ;;
            3)
                restore_bbr
                ;;
            4)
                config_swap
                ;;
            5)
                delete_swap
                ;;
            6)
                config_hostname
                ;;
            0)
                echo "Exiting."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        echo ""
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

main
