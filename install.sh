#!/usr/bin/env bash

# NixOS Configuration Installer
# Jake's Modular NixOS Configuration with Feature Flags

set -e  # Temporarily disabled to see errors

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Language selection
echo "🌍 Language / Idioma:"
echo "1) English"
echo "2) Português"
read -p "Choose/Escolha (1-2): " LANG_CHOICE

if [[ "$LANG_CHOICE" == "2" ]]; then
    LANG="pt_BR.UTF-8"
else
    LANG="en_US.UTF-8"
fi

# Get script directory to find language files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration variables
VARIABLES_FILE="${SCRIPT_DIR}/variables.sh"
if [[ -f "$VARIABLES_FILE" ]]; then
    echo -e "${BLUE}🔧 Carregando configurações customizadas...${NC}"
    source "$VARIABLES_FILE"
else
    echo -e "${YELLOW}⚠️ Usando configurações padrão (variables.sh não encontrado)${NC}"
    # Definir valores padrão inline se variables.sh não existir
    DOTFILES_REPO_URL="https://github.com/JakeMartinezz/hyprdots-nix"
    DOTFILES_BRANCH="main"
    NIXOS_CONFIG_PATH="/etc/nixos"
    MOUNT_POINT_PREFIX="/mnt"
    BACKUP_DIR_PREFIX="/etc/nixos.backup"
    DEFAULT_USERNAME="${USER:-jake}"
    DEFAULT_HOSTNAME="${HOSTNAME:-nixos}"
    DEFAULT_USER_DESCRIPTION="NixOS User"
    NETWORK_TIMEOUT=30
    MAX_RETRY_ATTEMPTS=3
    PRESET_FILENAME="preset.conf"
    DEFAULT_LANGUAGE="pt"
    DEFAULT_LOCALE="pt_BR.UTF-8"
    DEFAULT_TIMEZONE="America/Sao_Paulo"
    DEFAULT_MOUNT_OPTIONS="defaults,x-gvfs-show"
    MIN_FREE_SPACE_MB=2048
    INSTALLER_TITLE="NixOS Configuration Installer"
    WELCOME_MESSAGE="Bem-vindo ao instalador inteligente do NixOS!"
    SUCCESS_MESSAGE="Instalação concluída com sucesso!"
fi

# Load language strings from external files
if [[ "$LANG" == "pt_BR.UTF-8" ]]; then
    # Load Portuguese strings
    if [[ -f "${SCRIPT_DIR}/docs/portuguese/strings.sh" ]]; then
        source "${SCRIPT_DIR}/docs/portuguese/strings.sh"
    else
        echo "❌ Erro: Arquivo de strings em português não encontrado!"
        echo "Esperado em: ${SCRIPT_DIR}/docs/portuguese/strings.sh"
        exit 1
    fi
else
    # Load English strings
    if [[ -f "${SCRIPT_DIR}/docs/english/strings.sh" ]]; then
        source "${SCRIPT_DIR}/docs/english/strings.sh"
    else
        echo "❌ Error: English strings file not found!"
        echo "Expected at: ${SCRIPT_DIR}/docs/english/strings.sh"
        exit 1
    fi
fi

# Helper functions for language-specific messages
is_portuguese() {
    [[ "$LANG" == "pt_BR.UTF-8" ]]
}


# Function to check if running on NixOS
check_nixos() {
    echo -e "${BLUE}$MSG_NIXOS_CHECK${NC}"
    
    if [[ ! -f /etc/NIXOS ]]; then
        echo -e "${RED}$MSG_NOT_NIXOS${NC}"
        echo -e "${YELLOW}$MSG_INSTALLER_FOR_NIXOS${NC}"
        echo -e "${YELLOW}$MSG_NIXOS_FILE_NOT_FOUND${NC}"
        exit 1
    fi
}

# Function to check system dependencies
check_dependencies() {
    echo -e "${BLUE}$MSG_DEPENDENCY_CHECK${NC}"
    
    local required_commands=("lsblk" "base64" "nixos-generate-config" "sudo" "grep" "awk" "sed" "cp" "mv" "mkdir" "rm" "date" "ip")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo -e "${RED}$MSG_MISSING_DEPS${NC}"
        for cmd in "${missing_commands[@]}"; do
            echo -e "  ${YELLOW}- $cmd${NC}"
        done
        echo
        echo -e "${YELLOW}$MSG_INSTALL_DEPS${NC}"
        echo -e "${CYAN}$MSG_NIXOS_INSTALL_CMD${NC}"
        echo -e "${CYAN}  nix-env -iA nixos.util-linux nixos.coreutils nixos.iproute2${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}$MSG_DEPS_OK${NC}"
}

# GPU Detection Functions
detect_gpu_automatically() {
    local detected_type=""
    
    # Method 1: Try lspci (most reliable)
    if command -v lspci >/dev/null 2>&1; then
        local gpu_info
        gpu_info=$(lspci | grep -E -i "(vga|3d|display)" | head -1)
        
        if [[ -n "$gpu_info" ]]; then
            if [[ $gpu_info == *"NVIDIA"* ]] || [[ $gpu_info == *"GeForce"* ]] || [[ $gpu_info == *"Quadro"* ]]; then
                detected_type="nvidia"
            elif [[ $gpu_info == *"AMD"* ]] || [[ $gpu_info == *"Radeon"* ]] || [[ $gpu_info == *"ATI"* ]]; then
                detected_type="amd"
            elif [[ $gpu_info == *"Intel"* ]]; then
                detected_type="intel"
            fi
        fi
    fi
    
    # Method 2: Fallback to checking loaded kernel modules
    if [[ -z "$detected_type" ]] && [[ -f /proc/modules ]]; then
        local modules
        modules=$(cat /proc/modules)
        
        if [[ $modules == *"nvidia"* ]]; then
            detected_type="nvidia"
        elif [[ $modules == *"amdgpu"* ]] || [[ $modules == *"radeon"* ]]; then
            detected_type="amd"
        elif [[ $modules == *"i915"* ]]; then
            detected_type="intel"
        fi
    fi
    
    echo "$detected_type"
}

show_detected_gpu_info() {
    local gpu_type="$1"
    
    case "$gpu_type" in
        "nvidia")
            echo -e "  ${GREEN}🎮 $MSG_GPU_NVIDIA_DETECTED${NC}"
            echo -e "     $MSG_GPU_DRIVER_RECOMMENDATION $MSG_GPU_NVIDIA_PROPRIETARY"
            echo -e "     $MSG_GPU_CONFIG_TYPE \"nvidia\""
            ;;
        "amd") 
            echo -e "  ${GREEN}🔴 $MSG_GPU_AMD_DETECTED${NC}"
            echo -e "     $MSG_GPU_DRIVER_RECOMMENDATION $MSG_GPU_AMDGPU_OPENSOURCE"
            echo -e "     $MSG_GPU_CONFIG_TYPE \"amd\""
            ;;
        "intel")
            echo -e "  ${GREEN}🔵 $MSG_GPU_INTEL_DETECTED${NC}"
            echo -e "     $MSG_GPU_DRIVER_RECOMMENDATION $MSG_GPU_INTEL_OPENSOURCE"
            echo -e "     $MSG_GPU_CONFIG_TYPE \"intel\""
            ;;
        *)
            echo -e "  ${YELLOW}❓ $MSG_GPU_MANUAL${NC}"
            ;;
    esac
}

validate_system_requirements() {
    local validation_passed=true
    
    echo -e "${BLUE}$MSG_REQUIREMENTS_CHECK${NC}"
    echo
    
    # RAM Check
    if [[ -f /proc/meminfo ]]; then
        local ram_gb
        ram_gb=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024/1024)}')
        
        echo -e "  $MSG_RAM_DETECTED ${CYAN}${ram_gb}GB${NC}"
        
        if [[ $ram_gb -ge 2 ]]; then
            echo -e "  ${GREEN}✅ RAM: ${ram_gb}GB${NC}"
        elif [[ $ram_gb -ge 1 ]]; then
            echo -e "  ${YELLOW}⚠️  RAM: ${ram_gb}GB (minimum)${NC}"
        else
            echo -e "  ${RED}❌ $MSG_INSUFFICIENT_RAM: ${ram_gb}GB${NC}"
            validation_passed=false
        fi
    fi
    
    # Disk Space Check
    if command -v df >/dev/null; then
        local space_gb
        space_gb=$(df -BG / | tail -1 | awk '{print int($4)}')
        
        echo -e "  $MSG_DISK_SPACE_DETECTED ${CYAN}${space_gb}GB${NC}"
        
        if [[ $space_gb -ge 10 ]]; then
            echo -e "  ${GREEN}✅ Disk: ${space_gb}GB${NC}"
        else
            echo -e "  ${RED}❌ $MSG_INSUFFICIENT_DISK: ${space_gb}GB${NC}"
            validation_passed=false
        fi
    fi
    
    # Architecture Check
    local arch
    arch=$(uname -m)
    echo -e "  $MSG_ARCHITECTURE_DETECTED ${CYAN}$arch${NC}"
    
    case "$arch" in
        x86_64|amd64|aarch64|arm64)
            echo -e "  ${GREEN}✅ Architecture: $arch${NC}"
            ;;
        *)
            echo -e "  ${RED}❌ $MSG_UNSUPPORTED_ARCH: $arch${NC}"
            validation_passed=false
            ;;
    esac
    
    echo
    
    if [[ "$validation_passed" == "false" ]]; then
        echo -e "${RED}❌ $MSG_REQUIREMENTS_FAILED${NC}"
        echo -e "${YELLOW}$MSG_INSTALL_DEPS${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ $MSG_REQUIREMENTS_MET${NC}"
    fi
    
    echo
}

manual_gpu_selection() {
    echo
    echo -e "${YELLOW}$MSG_GPU:${NC}"
    echo "  1) amd"
    echo "  2) nvidia" 
    echo "  3) intel"

    while true; do
        read -p "$MSG_CHOICE_PROMPT " gpu_choice
        case $gpu_choice in
            1) gpu_type="amd"; break ;;
            2) gpu_type="nvidia"; break ;;
            3) gpu_type="intel"; break ;;
            *) 
                echo -e "${RED}$MSG_INVALID_CHOICE${NC}"
                ;;
        esac
    done
}

# Dotfiles Management Functions
choose_dotfiles_location() {
    echo -e "${YELLOW}$MSG_DOTFILES_LOCATION${NC}" >&2
    echo "  1) $MSG_DOTFILES_LOCATION_SCRIPT" >&2
    echo "  2) $MSG_DOTFILES_LOCATION_HIDDEN" >&2
    echo "  3) $MSG_DOTFILES_LOCATION_CUSTOM" >&2
    echo >&2
    
    while true; do
        read -p "$MSG_CHOICE_PROMPT " location_choice >&2
        case $location_choice in
            1) echo "$HOME/dotfiles"; return 0 ;;
            2) echo "$HOME/.dotfiles"; return 0 ;;
            3) 
                read -p "$MSG_DOTFILES_CUSTOM_PATH " custom_path >&2
                # Expand ~ if necessary
                custom_path="${custom_path/#\~/$HOME}"
                echo "$custom_path"
                return 0
                ;;
            *) 
                echo -e "${RED}$MSG_INVALID_CHOICE${NC}" >&2
                ;;
        esac
    done
}

find_existing_dotfiles() {
    local common_locations=(
        "$HOME/dotfiles"
        "$HOME/.dotfiles" 
        "$HOME/.config/dotfiles"
        "$(dirname "$0")/dotfiles"
    )
    
    for location in "${common_locations[@]}"; do
        if [[ -d "$location" ]] && [[ -n "$(ls -A "$location" 2>/dev/null)" ]]; then
            echo "$location"
            return 0
        fi
    done
    
    return 1
}

check_dotfiles_directory() {
    local desired_path="$1"
    
    # Check if it already exists in the desired location
    if [[ -d "$desired_path" ]]; then
        if [[ -n "$(ls -A "$desired_path" 2>/dev/null)" ]]; then
            echo "$desired_path"
            return 0  # Found in desired location
        else
            return 1  # Empty folder in desired location
        fi
    fi
    
    # Search in other locations
    local found_location
    if found_location=$(find_existing_dotfiles); then
        echo "$found_location"
        return 2  # Found in different location
    fi
    
    return 3  # Not found anywhere
}

relocate_dotfiles() {
    local current_path="$1"
    local desired_path="$2"
    
    echo -e "${YELLOW}$MSG_DOTFILES_EXISTS_ELSEWHERE${NC}" >&2
    echo -e "  Current: ${CYAN}$current_path${NC}" >&2
    echo -e "  Desired: ${CYAN}$desired_path${NC}" >&2
    echo >&2
    
    echo -e "${YELLOW}$MSG_DOTFILES_MOVE_OR_COPY${NC}" >&2
    echo "  1) $MSG_DOTFILES_MOVE" >&2
    echo "  2) $MSG_DOTFILES_COPY" >&2
    echo "  3) $MSG_DOTFILES_KEEP_CURRENT" >&2
    
    while true; do
        read -p "$MSG_CHOICE_PROMPT " move_choice >&2
        case $move_choice in
            1) # Move files
                echo -e "${BLUE}$MSG_DOTFILES_MOVING${NC}" >&2
                if mkdir -p "$(dirname "$desired_path")" && mv "$current_path" "$desired_path"; then
                    echo -e "${GREEN}$MSG_DOTFILES_RELOCATED${NC}" >&2
                    echo "$desired_path"
                    return 0
                else
                    echo -e "${RED}Failed to move dotfiles${NC}" >&2
                    return 1
                fi
                ;;
            2) # Copy files
                echo -e "${BLUE}$MSG_DOTFILES_COPYING${NC}" >&2
                if mkdir -p "$desired_path" && cp -r "$current_path/"* "$desired_path/"; then
                    echo -e "${GREEN}$MSG_DOTFILES_RELOCATED${NC}" >&2
                    echo "$desired_path"
                    return 0
                else
                    echo -e "${RED}Failed to copy dotfiles${NC}" >&2
                    return 1
                fi
                ;;
            3) # Keep current
                echo "$current_path"
                return 0
                ;;
            *) 
                echo -e "${RED}$MSG_INVALID_CHOICE${NC}" >&2
                ;;
        esac
    done
}

download_dotfiles() {
    local repo_url="$DOTFILES_REPO_URL"
    local dotfiles_path="$1"
    
    echo -e "${BLUE}$MSG_DOTFILES_DOWNLOADING${NC}"
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dotfiles_path")"
    
    # Clone repository
    if git clone "$repo_url" "$dotfiles_path"; then
        echo -e "${GREEN}✅ Dotfiles downloaded successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to download dotfiles${NC}"
        return 1
    fi
}

install_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        echo -e "${YELLOW}$MSG_STOW_NOT_FOUND${NC}"
        echo -e "${BLUE}$MSG_STOW_INSTALLING${NC}"
        
        # Install stow via nix-env or system
        if command -v nix-env >/dev/null 2>&1; then
            nix-env -iA nixos.stow
        else
            echo -e "${RED}Cannot install stow automatically${NC}"
            return 1
        fi
    fi
    
    return 0
}

apply_dotfiles() {
    local dotfiles_path="${1:-$HOME/dotfiles}"
    local user_home="$HOME"
    
    echo -e "${BLUE}$MSG_DOTFILES_APPLYING${NC}"
    echo -e "From: ${CYAN}$dotfiles_path${NC}"
    echo -e "To: ${CYAN}$user_home${NC}"
    echo
    
    # Check if stow is available
    if ! install_stow; then
        echo -e "${RED}$MSG_STOW_NOT_FOUND${NC}"
        return 1
    fi
    
    # Check if directory exists
    if [[ ! -d "$dotfiles_path" ]]; then
        echo -e "${RED}Dotfiles directory not found: $dotfiles_path${NC}"
        return 1
    fi
    
    # Apply dotfiles
    cd "$dotfiles_path"
    
    # Check for two different dotfiles structures:
    # 1. Packages structure: subdirectories with dotfiles inside each
    # 2. Direct structure: dotfiles directly in the main directory
    
    # First, try to find package directories (subdirectories)
    local stow_packages=()
    for dir in */; do
        if [[ -d "$dir" ]]; then
            stow_packages+=("${dir%/}")
        fi
    done
    
    # If we found packages, use package-based approach
    if [[ ${#stow_packages[@]} -gt 0 ]]; then
        echo -e "Found ${#stow_packages[@]} $MSG_DOTFILES_PACKAGES_FOUND ${stow_packages[*]}"
        echo
        
        # Apply each package
        for package in "${stow_packages[@]}"; do
            echo -e "  ${CYAN}Applying: $package${NC}"
            if stow -t "$user_home" "$package" 2>/dev/null; then
                echo -e "  ${GREEN}✅ $package applied${NC}"
            else
                echo -e "  ${YELLOW}⚠️  $package skipped (conflicts/errors)${NC}"
            fi
        done
    else
        # No packages found, check if we have dotfiles directly in this directory
        local has_dotfiles=false
        for item in .[^.]* *; do
            if [[ -e "$item" && "$item" != "." && "$item" != ".." ]]; then
                has_dotfiles=true
                break
            fi
        done
        
        if [[ "$has_dotfiles" == "true" ]]; then
            echo -e "$MSG_DOTFILES_DIRECT_STRUCTURE"
            echo
            
            # Apply entire directory as a single package using stow .
            if stow -d "$dotfiles_path" -t "$user_home" . 2>/dev/null; then
                echo -e "${GREEN}✅ Dotfiles applied successfully${NC}"
            else
                echo -e "${YELLOW}⚠️ Some dotfiles skipped (conflicts/errors)${NC}"
            fi
        else
            echo -e "${YELLOW}No stowable packages or dotfiles found${NC}"
            return 1
        fi
    fi
    
    echo
    echo -e "${GREEN}$MSG_DOTFILES_SUCCESS${NC}"
    return 0
}

prepare_dotfiles() {
    echo -e "${BLUE}$MSG_DOTFILES_CHECK${NC}"
    echo
    
    # First, ask if user wants to configure dotfiles at all
    if ask_yes_no "$MSG_DOTFILES_CONFIGURE" "y" | grep -q "false"; then
        echo -e "${YELLOW}$MSG_DOTFILES_SKIP${NC}"
        dotfiles_enabled="false"
        dotfiles_location=""
        return 1
    fi
    
    dotfiles_enabled="true"
    
    # Then choose desired location
    local desired_location
    desired_location=$(choose_dotfiles_location)
    echo -e "$MSG_DOTFILES_SELECTED_LOCATION ${CYAN}$desired_location${NC}"
    echo
    
    # Check dotfiles status
    local found_location
    found_location=$(check_dotfiles_directory "$desired_location")
    local check_result=$?
    
    case $check_result in
        0) # Found in desired location
            echo -e "${GREEN}$MSG_DOTFILES_FOUND${NC}"
            echo -e "Location: ${CYAN}$found_location${NC}"
            if ask_yes_no "Prepare dotfiles for application after rebuild?" "y" | grep -q "true"; then
                # Save location for later use
                echo "$found_location" > /tmp/nixos_dotfiles_path
                dotfiles_location="$found_location"
                echo -e "${GREEN}$MSG_DOTFILES_PREPARED${NC}"
                echo -e "${CYAN}$MSG_DOTFILES_WILL_APPLY${NC}"
                return 0
            else
                echo -e "${YELLOW}$MSG_DOTFILES_SKIP${NC}"
                dotfiles_enabled="false"
                dotfiles_location=""
                return 1
            fi
            ;;
        1) # Empty folder in desired location
            echo -e "${YELLOW}$MSG_DOTFILES_EMPTY${NC}"
            if ask_yes_no "$MSG_DOTFILES_DOWNLOAD" "y" | grep -q "true"; then
                if download_dotfiles "$desired_location"; then
                    # Save location for later use
                    echo "$desired_location" > /tmp/nixos_dotfiles_path
                    dotfiles_location="$desired_location"
                    echo -e "${GREEN}$MSG_DOTFILES_PREPARED${NC}"
                    echo -e "${CYAN}$MSG_DOTFILES_WILL_APPLY${NC}"
                    return 0
                fi
            else
                echo -e "${YELLOW}$MSG_DOTFILES_SKIP${NC}"
                dotfiles_enabled="false"
                dotfiles_location=""
                return 1
            fi
            ;;
        2) # Found in different location
            echo -e "${YELLOW}$MSG_DOTFILES_FOUND${NC}"
            echo -e "Found at: ${CYAN}$found_location${NC}"
            
            local final_location
            if final_location=$(relocate_dotfiles "$found_location" "$desired_location"); then
                if ask_yes_no "Prepare dotfiles for application after rebuild?" "y" | grep -q "true"; then
                    # Save location for later use
                    echo "$final_location" > /tmp/nixos_dotfiles_path
                    dotfiles_location="$final_location"
                    echo -e "${GREEN}$MSG_DOTFILES_PREPARED${NC}"
                    echo -e "${CYAN}$MSG_DOTFILES_WILL_APPLY${NC}"
                    return 0
                else
                    dotfiles_enabled="false"
                    dotfiles_location=""
                    return 1
                fi
            else
                echo -e "${RED}Failed to relocate dotfiles${NC}"
                dotfiles_enabled="false"
                dotfiles_location=""
                return 1
            fi
            ;;
        3) # Not found anywhere
            echo -e "${YELLOW}$MSG_DOTFILES_NOT_FOUND${NC}"
            if ask_yes_no "$MSG_DOTFILES_DOWNLOAD" "y" | grep -q "true"; then
                if download_dotfiles "$desired_location"; then
                    # Save location for later use
                    echo "$desired_location" > /tmp/nixos_dotfiles_path
                    dotfiles_location="$desired_location"
                    echo -e "${GREEN}$MSG_DOTFILES_PREPARED${NC}"
                    echo -e "${CYAN}$MSG_DOTFILES_WILL_APPLY${NC}"
                    return 0
                fi
            else
                echo -e "${YELLOW}$MSG_DOTFILES_SKIP${NC}"
                dotfiles_enabled="false"
                dotfiles_location=""
                return 1
            fi
            ;;
    esac
    
    return 1
}

apply_prepared_dotfiles() {
    # Check if there are prepared dotfiles
    if [[ ! -f /tmp/nixos_dotfiles_path ]]; then
        return 0  # Nothing prepared, no problem
    fi
    
    local dotfiles_path
    dotfiles_path=$(cat /tmp/nixos_dotfiles_path)
    
    if [[ ! -d "$dotfiles_path" ]]; then
        echo -e "${RED}Prepared dotfiles path not found: $dotfiles_path${NC}"
        rm -f /tmp/nixos_dotfiles_path
        return 1
    fi
    
    echo
    echo -e "${BLUE}$MSG_DOTFILES_APPLYING${NC}"
    echo -e "From: ${CYAN}$dotfiles_path${NC}"
    
    # Apply dotfiles
    if apply_dotfiles "$dotfiles_path"; then
        echo -e "${GREEN}$MSG_DOTFILES_SUCCESS${NC}"
        # Clean up temporary file
        rm -f /tmp/nixos_dotfiles_path
        return 0
    else
        echo -e "${RED}$MSG_DOTFILES_ERROR${NC}"
        return 1
    fi
}

# Function to run nixos-cleaner if user wants
run_nixos_cleaner() {
    echo
    if ask_yes_no "$MSG_CLEANER_OFFER" "n" | grep -q "true"; then
        echo -e "${BLUE}$MSG_CLEANER_RUNNING${NC}"
        
        # Check if nixos-cleaner is available
        if command -v nixos-cleaner >/dev/null 2>&1; then
            if nixos-cleaner; then
                echo -e "${GREEN}$MSG_CLEANER_SUCCESS${NC}"
            else
                echo -e "${RED}$MSG_CLEANER_ERROR${NC}"
            fi
        else
            # If nixos-cleaner is not available, run manual cleanup
            echo -e "${YELLOW}nixos-cleaner not found, running manual cleanup...${NC}"
            
            echo -e "${CYAN}Running nix-collect-garbage...${NC}"
            if nix-collect-garbage -d; then
                echo -e "${CYAN}Running nix-store --optimise...${NC}"
                if nix-store --optimise; then
                    echo -e "${GREEN}$MSG_CLEANER_SUCCESS${NC}"
                else
                    echo -e "${RED}$MSG_CLEANER_ERROR${NC}"
                fi
            else
                echo -e "${RED}$MSG_CLEANER_ERROR${NC}"
            fi
        fi
    fi
}

# Function to check if nixos-rebuild is available
check_nixos_rebuild() {
    if ! command -v "nixos-rebuild" >/dev/null 2>&1; then
        echo -e "${YELLOW}$MSG_NIXOS_REBUILD_NOT_FOUND${NC}"
        echo -e "${YELLOW}$MSG_NIXOS_NORMAL_ISO${NC}"
        echo -e "${YELLOW}$MSG_MANUAL_REBUILD_NEEDED${NC}"
        echo
    fi
}

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$MSG_TITLE${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}$MSG_WELCOME${NC}"
    echo
}

ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="(Y/n)"
    else
        prompt="(y/N)"
    fi
    
    read -p "$question $prompt: " answer
    answer=${answer:-$default}
    
    if is_portuguese; then
        [[ "$answer" =~ ^[sS]|^[yY] ]] && echo "true" || echo "false"
    else
        [[ "$answer" =~ ^[yY]|^[sS] ]] && echo "true" || echo "false"
    fi
}

ask_input() {
    local question="$1"
    local default="$2"
    local answer
    
    if [[ -n "$default" ]]; then
        read -p "$question [$default]: " answer
        answer=${answer:-$default}
    else
        read -p "$question: " answer
    fi
    
    echo "$answer"
}

ask_choice() {
    local question="$1"
    local choice1="$2"
    local choice2="$3"  
    local choice3="$4"
    
    echo -e "${YELLOW}$question${NC}"
    echo "  1) $choice1"
    echo "  2) $choice2"
    echo "  3) $choice3"
    
    while true; do
        read -p "$MSG_CHOICE_PROMPT " choice
        
        case $choice in
            1) echo "$choice1"; return ;;
            2) echo "$choice2"; return ;;
            3) echo "$choice3"; return ;;
            *)
                echo -e "${RED}$MSG_INVALID_CHOICE${NC}"
                ;;
        esac
    done
}

# Main installation
print_header

# System checks
check_nixos
check_dependencies
check_nixos_rebuild

echo -e "${YELLOW}$MSG_WARNING${NC}"
echo -e "  ${MSG_WARNING1}"
echo -e "  ${MSG_WARNING2}" 
echo -e "  ${MSG_WARNING3}"
echo

read -p "$MSG_CONTINUE: " continue_install
if is_portuguese; then
    [[ ! "$continue_install" =~ ^[sS] ]] && exit 0
else
    [[ ! "$continue_install" =~ ^[yY] ]] && exit 0
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}$MSG_ROOT_ERROR${NC}"
    exit 1
fi

# Configuration collection will happen before moving files
echo -e "${BLUE}$MSG_CONFIG${NC}"

# Global variables
configured_disks=""
dotfiles_enabled="false"
dotfiles_location=""
auto_update_enable="false"

# Configuration preset file (in script directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_FILE="$SCRIPT_DIR/$PRESET_FILENAME"

# Function to save configuration preset
save_config_preset() {
    echo "# NixOS Installer Configuration Preset" > "$PRESET_FILE"
    echo "# Generated on $(date)" >> "$PRESET_FILE"
    echo "username=$username" >> "$PRESET_FILE"
    echo "hostname=$hostname" >> "$PRESET_FILE"
    echo "gpu_type=$gpu_type" >> "$PRESET_FILE"
    echo "laptop_enable=$laptop_enable" >> "$PRESET_FILE"
    echo "bluetooth_enable=$bluetooth_enable" >> "$PRESET_FILE"
    echo "gaming_enable=$gaming_enable" >> "$PRESET_FILE"
    echo "development_enable=$development_enable" >> "$PRESET_FILE"
    echo "media_enable=$media_enable" >> "$PRESET_FILE"
    echo "virtualbox_enable=$virtualbox_enable" >> "$PRESET_FILE"
    echo "polkit_enable=$polkit_enable" >> "$PRESET_FILE"
    echo "fauxmo_enable=$fauxmo_enable" >> "$PRESET_FILE"
    echo "gtk_theme=$gtk_theme" >> "$PRESET_FILE"
    echo "gtk_icon=$gtk_icon" >> "$PRESET_FILE"
    echo "auto_update_enable=$auto_update_enable" >> "$PRESET_FILE"
    echo "dotfiles_enabled=$dotfiles_enabled" >> "$PRESET_FILE"
    echo "dotfiles_location=$dotfiles_location" >> "$PRESET_FILE"
    
    # Save configured disks (base64 encoded to handle special characters)
    if [[ -n "$configured_disks" ]]; then
        echo "configured_disks_b64=$(echo "$configured_disks" | base64 -w 0)" >> "$PRESET_FILE"
    fi
    
    echo -e "${GREEN}$MSG_CONFIG_SAVED_TO $PRESET_FILE${NC}"
}

# Helper function to validate and fix GPU type
validate_gpu_type() {
    if [[ "$gpu_type" != "amd" && "$gpu_type" != "nvidia" && "$gpu_type" != "intel" ]]; then
        echo -e "${RED}$MSG_INVALID_GPU_TYPE '$gpu_type'${NC}"
        echo -e "${YELLOW}$MSG_VALID_GPU_VALUES${NC}"
        
        gpu_type=$(ask_choice "$MSG_GPU" "amd" "nvidia" "intel")
        return 0  # indicates error was found and fixed
    fi
    return 1  # indicates no error
}

# Helper function to validate and fix GTK theme
validate_gtk_theme() {
    if [[ "$gtk_theme" != "catppuccin" && "$gtk_theme" != "gruvbox" && "$gtk_theme" != "gruvbox-material" ]]; then
        echo -e "${RED}❌ Invalid GTK theme: '$gtk_theme'${NC}"
        echo -e "${YELLOW}Valid values: catppuccin, gruvbox, gruvbox-material${NC}"
        
        gtk_theme=$(ask_choice "$MSG_THEME" "catppuccin" "gruvbox" "gruvbox-material")
        return 0  # indicates error was found and fixed
    fi
    return 1  # indicates no error
}

# Helper function to validate and fix GTK icon theme
validate_gtk_icon() {
    if [[ "$gtk_icon" != "tela-dracula" && "$gtk_icon" != "gruvbox-plus-icons" ]]; then
        echo -e "${RED}❌ Invalid icon theme: '$gtk_icon'${NC}"
        echo -e "${YELLOW}Valid values: tela-dracula, gruvbox-plus-icons${NC}"
        
        gtk_icon=$(ask_choice "$MSG_ICON" "tela-dracula" "gruvbox-plus-icons")
        return 0  # indicates error was found and fixed
    fi
    return 1  # indicates no error
}

# Helper function to validate and fix auto update setting
validate_auto_update() {
    if [[ "$auto_update_enable" != "true" && "$auto_update_enable" != "false" ]]; then
        echo -e "${RED}❌ Invalid auto update setting: '$auto_update_enable'${NC}"
        echo -e "${YELLOW}Valid values: true, false${NC}"
        
        auto_update_enable=$(ask_choice "Enable automatic system updates (weekly)?" "false" "true")
        return 0  # indicates error was found and fixed
    fi
    return 1  # indicates no error
}

# Helper function to validate and fix boolean values
validate_boolean_values() {
    local has_errors=false
    local boolean_vars=("laptop_enable" "bluetooth_enable" "gaming_enable" "development_enable" "media_enable" "virtualbox_enable" "polkit_enable" "fauxmo_enable")
    local boolean_messages=("$MSG_LAPTOP" "$MSG_BLUETOOTH" "$MSG_GAMING" "$MSG_DEVELOPMENT" "$MSG_MEDIA" "$MSG_VIRTUALBOX" "$MSG_POLKIT" "$MSG_FAUXMO")
    
    for i in "${!boolean_vars[@]}"; do
        local var_name="${boolean_vars[$i]}"
        local var_value="${!var_name}"
        local var_message="${boolean_messages[$i]}"
        
        if [[ "$var_value" != "true" && "$var_value" != "false" ]]; then
            echo -e "${RED}$MSG_INVALID_BOOLEAN $var_name: '$var_value'${NC}"
            echo -e "${YELLOW}$MSG_BOOLEAN_VALUES${NC}"
            
            declare "$var_name=$(ask_yes_no "$var_message")"
            has_errors=true
        fi
    done
    
    [[ "$has_errors" == "true" ]] && return 0 || return 1
}

# Helper function to validate and fix username
validate_username() {
    if [[ -z "$username" || ! "$username" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        echo -e "${RED}$MSG_INVALID_USERNAME '$username'${NC}"
        echo -e "${YELLOW}$MSG_USERNAME_RULES${NC}"
        
        username=$(ask_input "$MSG_USERNAME")
        return 0  # indicates error was found and fixed
    fi
    return 1  # indicates no error
}

# Helper function to validate and fix hostname
validate_hostname() {
    if [[ -z "$hostname" || ! "$hostname" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
        echo -e "${RED}$MSG_INVALID_HOSTNAME '$hostname'${NC}"
        echo -e "${YELLOW}$MSG_HOSTNAME_RULES${NC}"
        
        hostname=$(ask_input "$MSG_HOSTNAME")
        return 0  # indicates error was found and fixed
    fi
    return 1  # indicates no error
}

# Helper function to handle corrections saving
handle_corrections_saving() {
    echo
    echo -e "${GREEN}$MSG_CONFIG_FIXED${NC}"
    echo -e "${BLUE}$MSG_SAVE_CORRECTIONS_QUESTION${NC}"
    
    local save_corrections=$(ask_yes_no "$MSG_SAVE_CORRECTIONS" "y")
    if [[ "$save_corrections" == "true" ]]; then
        # Re-encode configured disks for saving if they exist
        if [[ -n "$configured_disks" ]]; then
            configured_disks_b64=$(echo "$configured_disks" | base64 -w 0)
        fi
        save_config_preset
    fi
    echo
}

# Function to validate dotfiles configuration
validate_dotfiles_config() {
    # Set defaults if missing
    [[ -z "$dotfiles_enabled" ]] && dotfiles_enabled="false"
    [[ -z "$dotfiles_location" ]] && dotfiles_location=""
    
    # Validate dotfiles_enabled is boolean
    if [[ "$dotfiles_enabled" != "true" && "$dotfiles_enabled" != "false" ]]; then
        echo -e "${RED}❌ Invalid dotfiles_enabled: $dotfiles_enabled${NC}"
        echo -e "${YELLOW}Setting to: false${NC}"
        dotfiles_enabled="false"
        return 0  # Has error
    fi
    
    return 1  # No error
}

# Function to validate and fix preset configuration
validate_and_fix_preset_config() {
    local has_errors=false
    
    # Validate and fix each component
    validate_gpu_type && has_errors=true
    validate_gtk_theme && has_errors=true
    validate_gtk_icon && has_errors=true
    validate_auto_update && has_errors=true
    validate_boolean_values && has_errors=true
    validate_username && has_errors=true
    validate_hostname && has_errors=true
    validate_dotfiles_config && has_errors=true
    
    # If there were errors, handle corrections saving
    if [[ "$has_errors" == "true" ]]; then
        handle_corrections_saving
    fi
    
    return 0
}

# Function to load configuration preset
load_config_preset() {
    if [[ -f "$PRESET_FILE" ]]; then
        source "$PRESET_FILE"
        
        # Store original configured_disks_b64 before validation
        original_configured_disks_b64="$configured_disks_b64"
        
        # Decode configured disks if present
        if [[ -n "$configured_disks_b64" ]]; then
            configured_disks=$(echo "$configured_disks_b64" | base64 -d)
        fi
        
        # Validate and fix loaded configuration
        validate_and_fix_preset_config
        
        # Restore configured_disks_b64 if it was lost during validation
        if [[ -z "$configured_disks_b64" && -n "$original_configured_disks_b64" ]]; then
            configured_disks_b64="$original_configured_disks_b64"
        fi
        
        return 0
    else
        return 1
    fi
}

# Helper function to display basic configuration info
show_basic_config() {
    echo -e "  ${YELLOW}Username:${NC} $username"
    echo -e "  ${YELLOW}Hostname:${NC} $hostname"
    echo -e "  ${YELLOW}GPU Type:${NC} $gpu_type"
    echo -e "  ${YELLOW}Laptop:${NC} $laptop_enable"
    echo -e "  ${YELLOW}Bluetooth:${NC} $bluetooth_enable"
    echo -e "  ${YELLOW}Gaming:${NC} $gaming_enable"
    echo -e "  ${YELLOW}Development:${NC} $development_enable"
    echo -e "  ${YELLOW}Media:${NC} $media_enable"
    echo -e "  ${YELLOW}VirtualBox:${NC} $virtualbox_enable"
    echo -e "  ${YELLOW}Polkit GNOME:${NC} $polkit_enable"
    echo -e "  ${YELLOW}Fauxmo/Alexa:${NC} $fauxmo_enable"
}

# Helper function to parse and display disk details
show_disk_details() {
    local configured_disks="$1"
    
    echo -e "    ${CYAN}$MSG_DISK_DETAILS${NC}"
    while IFS= read -r line; do
        if [[ "$line" =~ disco[0-9]+ ]]; then
            # Extract disk name
            local disk_name=$(echo "$line" | sed -n 's/.*\(disco[0-9]\+\).*/\1/p')
            echo -e "      ${GREEN}• $disk_name:${NC}"
        elif [[ "$line" =~ uuid\ =\ \"([^\"]+)\" ]]; then
            # Extract UUID
            local uuid=$(echo "$line" | sed -n 's/.*uuid = "\([^"]*\)".*/\1/p')
            echo -e "        UUID: $uuid"
        elif [[ "$line" =~ mountPoint\ =\ \"([^\"]+)\" ]]; then
            # Extract mount point
            local mount_point=$(echo "$line" | sed -n 's/.*mountPoint = "\([^"]*\)".*/\1/p')
            echo -e "        $MSG_MOUNT_TEXT ${CYAN}$mount_point${NC}"
        elif [[ "$line" =~ fsType\ =\ \"([^\"]+)\" ]]; then
            # Extract filesystem type
            local fstype=$(echo "$line" | sed -n 's/.*fsType = "\([^"]*\)".*/\1/p')
            echo -e "        $MSG_FILESYSTEM_TEXT $fstype"
        elif [[ "$line" =~ options\ =\ \[(.*)\] ]]; then
            # Extract options
            local options=$(echo "$line" | sed -n 's/.*options = \[\(.*\)\].*/\1/p')
            echo -e "        $MSG_OPTIONS_TEXT $options"
        fi
    done <<< "$configured_disks"
}

# Helper function to show preset creation date
show_preset_date() {
    if [[ -f "$PRESET_FILE" ]]; then
        local preset_date=$(grep "^# Generated on" "$PRESET_FILE" | sed 's/^# Generated on //')
        if [[ -n "$preset_date" ]]; then
            echo -e "  ${GRAY}$MSG_CONFIG_CREATED_ON $preset_date${NC}"
        fi
    fi
}

# Function to show preset configuration
show_preset_config() {
    echo
    echo -e "${BLUE}$MSG_SAVED_CONFIG_FOUND${NC}"
    
    show_basic_config
    
    if [[ -n "$configured_disks" ]]; then
        local disk_count=$(echo "$configured_disks" | grep -c "uuid =")
        echo -e "  ${YELLOW}Additional Disks:${NC} $disk_count $MSG_CONFIGURED_TEXT"
        show_disk_details "$configured_disks"
    else
        echo -e "  ${YELLOW}Additional Disks:${NC} $MSG_NONE_TEXT"
    fi
    
    # Show dotfiles configuration
    if [[ "$dotfiles_enabled" == "true" ]]; then
        echo -e "  ${YELLOW}Dotfiles:${NC} enabled"
        if [[ -n "$dotfiles_location" ]]; then
            echo -e "  ${YELLOW}Dotfiles Location:${NC} $dotfiles_location"
        fi
    else
        echo -e "  ${YELLOW}Dotfiles:${NC} disabled"
    fi
    
    show_preset_date
    echo
}

# Helper function to display disk information
display_disk_info() {
    local disk_count="$1"
    local name="$2"
    local size="$3"
    local fstype="$4"
    local uuid="$5"
    local label="$6"
    
    echo -e "  ${GREEN}[$disk_count]${NC} /dev/$name"
    echo -e "      $MSG_DISK_SIZE $size"
    echo -e "      $MSG_DISK_FILESYSTEM $fstype"
    echo -e "      UUID: $uuid"
    if [[ -n "$label" ]]; then
        echo -e "      $MSG_DISK_LABEL ${CYAN}$label${NC}"
    else
        echo -e "      $MSG_DISK_LABEL ${YELLOW}$MSG_NO_LABEL${NC}"
    fi
    echo
}

# Helper function to get mount options from user
get_mount_options() {
    local default_options="$DEFAULT_MOUNT_OPTIONS"
    
    echo >&2
    echo -e "${YELLOW}$MSG_MOUNT_OPTIONS_DISK${NC}" >&2
    echo -e "${CYAN}$MSG_RECOMMENDED_OPTIONS $default_options${NC}" >&2
    echo -e "${CYAN}  $MSG_DEFAULTS_OPTION${NC}" >&2
    echo -e "${CYAN}  $MSG_GVFS_OPTION${NC}" >&2
    echo >&2
    
    local use_default_options=$(ask_yes_no "$MSG_USE_DEFAULT_OPTIONS" "y")
    
    if [[ "$use_default_options" == "true" ]]; then
        echo "$default_options"
    else
        echo >&2
        echo -e "${YELLOW}$MSG_COMMON_MOUNT_OPTIONS${NC}" >&2
        echo -e "  ${GREEN}defaults${NC}           - $MSG_DEFAULTS_DESC" >&2
        echo -e "  ${GREEN}x-gvfs-show${NC}        - $MSG_GVFS_DESC" >&2
        echo -e "  ${GREEN}noatime${NC}            - $MSG_NOATIME_DESC" >&2
        echo -e "  ${GREEN}user${NC}               - $MSG_USER_DESC" >&2
        echo -e "  ${GREEN}compress=zstd${NC}      - $MSG_COMPRESS_DESC" >&2
        echo -e "  ${GREEN}subvol=@${NC}           - $MSG_SUBVOL_DESC" >&2
        echo >&2
        ask_input "$MSG_ENTER_MOUNT_OPTIONS" "$default_options"
    fi
}

# Helper function to convert mount options to Nix array format
convert_to_nix_options() {
    local mount_options="$1"
    local nix_options="[ "
    
    IFS=',' read -ra options_array <<< "$mount_options"
    for option in "${options_array[@]}"; do
        option=$(echo "$option" | xargs)  # trim whitespace
        nix_options="$nix_options\"$option\" "
    done
    nix_options="$nix_options]"
    
    echo "$nix_options"
}

# Helper function to determine default mount point
get_default_mount_point() {
    local disk_index="$1"
    local label="$2"
    
    if [[ -n "$label" ]]; then
        # Convert label to lowercase and replace spaces/special chars with dashes
        local sanitized_label=$(echo "$label" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
        echo "$MOUNT_POINT_PREFIX/$sanitized_label"
    else
        echo "$MOUNT_POINT_PREFIX/disco$disk_index"
    fi
}

# Helper function to configure a single disk
configure_single_disk() {
    local disk_index="$1"
    local name="$2"
    local uuid="$3"
    local fstype="$4"
    local size="$5"
    local label="$6"
    
    echo
    echo -e "${YELLOW}$MSG_DISK_INFO /dev/$name ($size, $fstype):${NC}"
    echo -e "${YELLOW}UUID: $uuid${NC}"
    if [[ -n "$label" ]]; then
        echo -e "${YELLOW}Label: ${CYAN}$label${NC}"
    fi
    
    local configure_disk=$(ask_yes_no "$MSG_CONFIGURE_DISK" "n")
    
    if [[ "$configure_disk" == "true" ]]; then
        local default_mount=$(get_default_mount_point "$disk_index" "$label")
        
        local mount_point=$(ask_input "$MSG_MOUNT_POINT" "$default_mount")
        mount_point=${mount_point:-$default_mount}
        
        local mount_options=$(get_mount_options)
        local nix_options=$(convert_to_nix_options "$mount_options")
        
        # Store disk configuration
        configured_disks="${configured_disks}      disco$disk_index = {
        uuid = \"$uuid\";
        mountPoint = \"$mount_point\";
        fsType = \"$fstype\";
        options = $nix_options;
      };
"
        
        echo -e "${GREEN}$MSG_DISK_CONFIGURED $mount_point $MSG_WITH_OPTIONS [$mount_options]${NC}"
        return 0
    fi
    
    return 1
}

# Function to detect additional disks
detect_additional_disks() {
    echo -e "${BLUE}$MSG_DETECTING_DISKS${NC}"
    
    # Get current root disk
    local root_disk=$(df / | tail -1 | awk '{print $1}' | sed 's|/dev/||' | sed 's|[0-9]*$||')
    
    # Find additional disks with partitions (including labels)
    local additional_disks=$(lsblk -rno NAME,SIZE,TYPE,FSTYPE,UUID,LABEL | grep -E "(disk|part)" | grep -v "$root_disk")
    
    local disk_count=0
    
    if [[ -n "$additional_disks" ]]; then
        echo
        echo -e "${YELLOW}$MSG_ADDITIONAL_DISKS_DETECTED${NC}"
        echo
        
        # Array to store disk info
        declare -A disk_info
        
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                local name=$(echo "$line" | awk '{print $1}')
                local size=$(echo "$line" | awk '{print $2}')
                local type=$(echo "$line" | awk '{print $3}')
                local fstype=$(echo "$line" | awk '{print $4}')
                local uuid=$(echo "$line" | awk '{print $5}')
                local label=$(echo "$line" | awk '{print $6}')
                
                # Only show partitions with filesystem and UUID
                if [[ "$type" == "part" && -n "$fstype" && -n "$uuid" && "$fstype" != "swap" ]]; then
                    disk_count=$((disk_count + 1))
                    
                    display_disk_info "$disk_count" "$name" "$size" "$fstype" "$uuid" "$label"
                    
                    disk_info["$disk_count,name"]="$name"
                    disk_info["$disk_count,size"]="$size"
                    disk_info["$disk_count,fstype"]="$fstype"
                    disk_info["$disk_count,uuid"]="$uuid"
                    disk_info["$disk_count,label"]="$label"
                fi
            fi
        done <<< "$additional_disks"
        
        if [[ $disk_count -gt 0 ]]; then
            # Ask if user wants to configure additional disks
            local use_disks=$(ask_yes_no "$MSG_CONFIGURE_ADDITIONAL_DISKS" "n")
            
            if [[ "$use_disks" == "true" ]]; then
                echo
                echo -e "${BLUE}$MSG_CONFIGURING_DISKS${NC}"
                
                for ((i=1; i<=disk_count; i++)); do
                    configure_single_disk "$i" "${disk_info["$i,name"]}" "${disk_info["$i,uuid"]}" "${disk_info["$i,fstype"]}" "${disk_info["$i,size"]}" "${disk_info["$i,label"]}" || true
                done
            fi
        else
            echo -e "${YELLOW}$MSG_NO_VALID_PARTITIONS${NC}"
        fi
    else
        echo -e "${GREEN}$MSG_NO_ADDITIONAL_DISKS${NC}"
    fi
}

# Function to collect all user information
collect_config() {
    # System validation first
    validate_system_requirements
    
    # Collect basic system info
    read -p "$MSG_USERNAME [$DEFAULT_USERNAME]: " username
    username="${username:-$DEFAULT_USERNAME}"
    read -p "$MSG_HOSTNAME [$DEFAULT_HOSTNAME]: " hostname
    hostname="${hostname:-$DEFAULT_HOSTNAME}"

    # GPU Detection
    echo -e "${BLUE}$MSG_GPU_DETECTION${NC}"
    
    local detected_gpu
    detected_gpu=$(detect_gpu_automatically)
    
    if [[ -n "$detected_gpu" ]]; then
        echo
        echo -e "${GREEN}$MSG_GPU_DETECTED${NC}"
        show_detected_gpu_info "$detected_gpu"
        echo
        
        # Ask for confirmation
        if [[ $(ask_yes_no "$MSG_GPU_CONFIRM" "y") == "true" ]]; then
            gpu_type="$detected_gpu"
            echo -e "${GREEN}✅ Using detected GPU: $gpu_type${NC}"
        else
            # Manual selection if user rejects detection
            manual_gpu_selection
        fi
    else
        # Manual selection if detection fails
        echo -e "${YELLOW}$MSG_GPU_MANUAL${NC}"
        manual_gpu_selection
    fi
    
    # Continue with rest of configuration
    laptop_enable=$(ask_yes_no "$MSG_LAPTOP")
    bluetooth_enable=$(ask_yes_no "$MSG_BLUETOOTH")
    gaming_enable=$(ask_yes_no "$MSG_GAMING")
    development_enable=$(ask_yes_no "$MSG_DEVELOPMENT")  
    media_enable=$(ask_yes_no "$MSG_MEDIA")
    virtualbox_enable=$(ask_yes_no "$MSG_VIRTUALBOX")
    polkit_enable=$(ask_yes_no "$MSG_POLKIT" "y")
    fauxmo_enable=$(ask_yes_no "$MSG_FAUXMO")
    
    # Auto Updates Configuration
    if ask_yes_no "$MSG_AUTO_UPDATE" "n"; then
        auto_update_enable="true"
    else
        auto_update_enable="false"
    fi
    
    # GTK Theme Selection
    echo
    echo -e "${BLUE}$MSG_THEME_SELECTION${NC}"
    echo -e "${YELLOW}$MSG_THEME${NC}"
    echo "  1) catppuccin"
    echo "  2) gruvbox"
    echo "  3) gruvbox-material"
    
    while true; do
        read -p "$MSG_CHOICE_PROMPT " choice
        case $choice in
            1) gtk_theme="catppuccin"; break ;;
            2) gtk_theme="gruvbox"; break ;;
            3) gtk_theme="gruvbox-material"; break ;;
            *) echo -e "${RED}$MSG_INVALID_CHOICE${NC}" ;;
        esac
    done
    
    # Icon Theme Selection
    echo
    echo -e "${BLUE}$MSG_ICON_SELECTION${NC}"
    echo -e "${YELLOW}$MSG_ICON${NC}"
    echo "  1) tela-dracula"
    echo "  2) gruvbox-plus-icons"
    
    while true; do
        read -p "$MSG_CHOICE_PROMPT " choice
        case $choice in
            1) gtk_icon="tela-dracula"; break ;;
            2) gtk_icon="gruvbox-plus-icons"; break ;;
            *) echo -e "${RED}$MSG_INVALID_CHOICE${NC}" ;;
        esac
    done

    # Detect and configure additional disks
    detect_additional_disks
    
    # 🔥 NOVA SEÇÃO: Preparar dotfiles ANTES do rebuild
    echo
    prepare_dotfiles || true  # Continue even if user chooses not to configure dotfiles
}

# Function to display configuration review
show_config_review() {
    echo
    echo -e "${BLUE}$MSG_REVIEW${NC}"
    echo -e "  ${YELLOW}Username:${NC} $username"
    echo -e "  ${YELLOW}Hostname:${NC} $hostname"
    echo -e "  ${YELLOW}GPU Type:${NC} $gpu_type"
    echo -e "  ${YELLOW}Laptop:${NC} $laptop_enable"
    echo -e "  ${YELLOW}Bluetooth:${NC} $bluetooth_enable"
    echo -e "  ${YELLOW}Gaming:${NC} $gaming_enable"
    echo -e "  ${YELLOW}Development:${NC} $development_enable"
    echo -e "  ${YELLOW}Media:${NC} $media_enable"
    echo -e "  ${YELLOW}VirtualBox:${NC} $virtualbox_enable"
    echo -e "  ${YELLOW}Polkit GNOME:${NC} $polkit_enable"
    echo -e "  ${YELLOW}Fauxmo/Alexa:${NC} $fauxmo_enable"
    echo -e "  ${YELLOW}GTK Theme:${NC} $gtk_theme"
    echo -e "  ${YELLOW}Icon Theme:${NC} $gtk_icon"
    echo -e "  ${YELLOW}Auto Updates:${NC} $auto_update_enable"
    echo -e "  ${YELLOW}$MSG_DOTFILES_ENABLED${NC} $dotfiles_enabled"
    if [[ "$dotfiles_enabled" == "true" && -n "$dotfiles_location" ]]; then
        echo -e "  ${YELLOW}$MSG_DOTFILES_LOCATION_DISPLAY${NC} $dotfiles_location"
    fi
    if [[ -n "$configured_disks" ]]; then
        echo -e "  ${YELLOW}Additional Disks:${NC} Configured"
        # Show configured disks count
        disk_lines=$(echo "$configured_disks" | grep -c "uuid =")
        echo -e "  ${YELLOW}Disks Count:${NC} $disk_lines"
    else
        echo -e "  ${YELLOW}Additional Disks:${NC} None"
    fi
    echo
}

# Check for existing configuration preset
use_preset=false
if load_config_preset; then
    echo -e "${GREEN}$MSG_PRESET_FOUND${NC}"
    
    show_preset_config
    
    use_preset=$(ask_yes_no "$MSG_USE_PRESET" "y")
    
    if [[ "$use_preset" == "true" ]]; then
        # Get network interface for saved config
        network_interface=$(ip route | grep default | awk '{print $5}' | head -1)
        echo -e "${GREEN}$MSG_USING_SAVED${NC}"
        
        # Process dotfiles configuration from preset
        if [[ "$dotfiles_enabled" == "true" && -n "$dotfiles_location" ]]; then
            echo "$dotfiles_location" > /tmp/nixos_dotfiles_path
        fi
    else
        echo -e "${YELLOW}$MSG_IGNORED_MSG${NC}"
        echo
    fi
fi

# Main configuration loop (skip if using preset)
if [[ "$use_preset" != "true" ]]; then
    while true; do
        collect_config
        network_interface=$(ip route | grep default | awk '{print $5}' | head -1)
        
        show_config_review
        
        confirm=$(ask_yes_no "$MSG_CONFIRM" "y")
        
        if [[ "$confirm" == "true" ]]; then
            # Ask if user wants to save this configuration
            echo
            save_preset=$(ask_yes_no "$MSG_SAVE_PRESET" "y")
            if [[ "$save_preset" == "true" ]]; then
                save_config_preset
            fi
            break
        else
            echo -e "${YELLOW}$MSG_CHANGE${NC}"
            echo
        fi
    done
fi

echo -e "${BLUE}$MSG_GENERATING${NC}"

# Generate variables.nix
cat > /tmp/variables.nix << EOF
{  
  # User configuration
  username = "$username";
  userDescription = "${username^}";
  userGroups = [ "networkmanager" "wheel" ];
  
  # System configuration
  hostname = "$hostname";
  stateVersion = "25.05";
  
  # Feature flags for hardware and services
  features = {
    # GPU Configuration
    gpu = {
      type = "$gpu_type"; # "amd", "nvidia", or "intel"
      
      # AMD-specific settings
      amd = {
        enable = $([ "$gpu_type" == "amd" ] && echo "true" || echo "false");
        optimizations = {
          RADV_PERFTEST = "aco";
          MESA_GL_THREAD = "true";
        };
      };
      
      # NVIDIA-specific settings
      nvidia = {
        enable = $([ "$gpu_type" == "nvidia" ] && echo "true" || echo "false");
        prime = {
          enable = false;
          sync = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        optimizations = {
          WLR_NO_HARDWARE_CURSORS = "1";
          NIXOS_OZONE_WL = "1";
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
      };
    };
    
    # Bluetooth support
    bluetooth = {
      enable = $bluetooth_enable;
      powerOnBoot = $bluetooth_enable;
      packages = [ "bluez" "bluez-tools" "blueman" ];
    };
    
    # Laptop-specific features
    laptop = {
      enable = $laptop_enable;
      packages = [ "wpa_supplicant" "hyprlock" ];
    };
    
    # Package categories
    packages = {
      gaming = {
        enable = $gaming_enable;
      };
      development = {
        enable = $development_enable;
      };
      media = {
        enable = $media_enable;
      };
    };
    
    # GTK Theme configuration
    gtk = {
      theme = "$gtk_theme";
      icon = "$gtk_icon";
    };
    
    # Services and integrations
    services = {
      # Fauxmo
      fauxmo = {
        enable = $fauxmo_enable;
        ports = [ 52002 ]; # TCP ports to open for Fauxmo service
      };
      
      # VirtualBox
      virtualbox = {
        enable = $virtualbox_enable;
      };
      
      # Polkit GNOME
      polkit_gnome = {
        enable = $polkit_enable;
      };
      
      # Garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      
      # Auto updates
      autoUpdate = {
        enable = $auto_update_enable;
      };
    };
    
    # Network features
    network = {
      wakeOnLan = {
        enable = true; 
        interface = "$network_interface";
      };
    };
  };
  
  # Filesystem configuration
  filesystems = {
    drives = {
$(if [[ -n "$configured_disks" ]]; then
echo "$configured_disks"
else
echo "      # No additional disks configured"
fi)
    };
  };
  
  # Paths and directories
  paths = {
    # NixOS configuration path
    configPath = "$NIXOS_CONFIG_PATH";
  };
  
  # Build and performance settings
  build = {
    # Detected automatically but can be overridden
    maxJobs = "auto";
    cores = 0; # Use all cores
    
    # Cache settings
    keepOutputs = true;
    keepDerivations = true;
    autoOptimiseStore = true;
  };
  
}
EOF

# Now that configuration is complete, ask for backup and move files
echo
echo -e "${BLUE}$MSG_CONFIG_COMPLETE${NC}"
echo

# Ask if user wants backup
do_backup=$(ask_yes_no "$MSG_BACKUP_ASK" "y")

if [[ "$do_backup" == "true" ]]; then
    echo -e "${BLUE}$MSG_BACKUP_CURRENT${NC}"
    
    if [ -d "$NIXOS_CONFIG_PATH" ]; then
        backup_dir="${BACKUP_DIR_PREFIX}.$(date +%Y%m%d_%H%M%S)"
        sudo cp -r "$NIXOS_CONFIG_PATH" "$backup_dir"
        echo -e "${GREEN}$MSG_BACKUP_CREATED $backup_dir${NC}"
    else
        echo -e "${YELLOW}$MSG_NO_BACKUP_FOUND${NC}"
    fi
fi

echo -e "${BLUE}$MSG_INSTALLING_CONFIG${NC}"

TEMP_DIR=$(mktemp -d)

# Copy only necessary files for NixOS configuration
echo -e "${CYAN}$MSG_COPYING_FILES${NC}"

# Create directory structure
mkdir -p "$TEMP_DIR/config"
mkdir -p "$TEMP_DIR/lib"
mkdir -p "$TEMP_DIR/modules"


cp nixos/flake.nix "$TEMP_DIR/" 2>/dev/null || true
cp nixos/flake.lock "$TEMP_DIR/" 2>/dev/null || true
cp nixos/configuration.nix "$TEMP_DIR/" 2>/dev/null || true
cp nixos/home.nix "$TEMP_DIR/" 2>/dev/null || true

# Copy configuration and modules directories from nixos/ subdirectory
cp -r nixos/config/* "$TEMP_DIR/config/" 2>/dev/null || true
cp -r nixos/lib/* "$TEMP_DIR/lib/" 2>/dev/null || true  
cp -r nixos/modules/* "$TEMP_DIR/modules/" 2>/dev/null || true

# Clean and copy new configuration
sudo rm -rf $NIXOS_CONFIG_PATH/*
sudo cp -r "$TEMP_DIR/"* $NIXOS_CONFIG_PATH/
sudo chown -R root:root $NIXOS_CONFIG_PATH

echo -e "${GREEN}$MSG_FILES_COPIED${NC}"

# Move the generated variables.nix to correct location
sudo mv /tmp/variables.nix $NIXOS_CONFIG_PATH/config/variables.nix
sudo chown root:root $NIXOS_CONFIG_PATH/config/variables.nix

# Generate hardware configuration for current system
echo -e "${BLUE}$MSG_GENERATING_HW${NC}"

LC_ALL=C sudo nixos-generate-config

echo -e "${GREEN}$MSG_HW_GENERATED${NC}"

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${GREEN}$MSG_CONFIG_INSTALLED${NC}"
echo

# Ask if user wants automatic rebuild
do_rebuild=$(ask_yes_no "$MSG_REBUILD_ASK" "n")

if [[ "$do_rebuild" == "true" ]]; then
    echo -e "${BLUE}$MSG_REBUILDING${NC}"
    if sudo nixos-rebuild switch --flake $NIXOS_CONFIG_PATH#default; then
        echo -e "${GREEN}$MSG_REBUILD_SUCCESS${NC}"
        rebuild_success="true"
        
        # 🔥 NOVA SEÇÃO: Aplicar dotfiles preparados
        apply_prepared_dotfiles
        
        # Offer to run nixos-cleaner after successful rebuild
        run_nixos_cleaner
        
    else
        echo -e "${RED}$MSG_REBUILD_FAILED${NC}"
        rebuild_success="false"
        # Limpar preparação se rebuild falhou
        rm -f /tmp/nixos_dotfiles_path
    fi
else
    # If user chose not to rebuild, still offer cleaner
    run_nixos_cleaner
fi

# Show comprehensive installation summary
show_installation_summary() {
    echo
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}         RESUMO DA INSTALAÇÃO           ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo
    echo -e "${GREEN}✅ Configuração aplicada com sucesso!${NC}"
    echo -e "   ${CYAN}• Username:${NC} $username"
    echo -e "   ${CYAN}• Hostname:${NC} $hostname" 
    echo -e "   ${CYAN}• GPU:${NC} $gpu_type"
    echo -e "   ${CYAN}• Configuração:${NC} $NIXOS_CONFIG_PATH"
    
    if [[ "$rebuild_success" == "true" ]]; then
        echo -e "   ${GREEN}• Sistema reconstruído com sucesso${NC}"
    else
        echo -e "   ${YELLOW}• Sistema não foi reconstruído${NC}"
    fi
    
    echo
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo
}

show_installation_summary

echo -e "${GREEN}$MSG_COMPLETE${NC}"
if [[ "$do_rebuild" == "false" ]]; then
    echo -e "${YELLOW}$MSG_REBUILD${NC}"
fi
echo
echo -e "${BLUE}$MSG_NEXT_STEPS${NC}"
echo -e "  $MSG_STEP1"
echo -e "  $MSG_STEP2"
echo -e "  $MSG_STEP3"
echo -e "  $MSG_STEP4"
echo
