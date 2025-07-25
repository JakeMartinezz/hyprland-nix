#!/bin/bash
# =============================================================================
# NIXOS INSTALLER - ESSENTIAL CONFIGURATIONS
# =============================================================================
# This file contains the main configurations that can be customized
# by the user without modifying the main script.

# =============================================================================
# 📁 REPOSITORIES AND URLS
# =============================================================================

# Main dotfiles repository
DOTFILES_REPO_URL="https://github.com/JakeMartinezz/hyprdots-nix"

# Default branch for cloning
DOTFILES_BRANCH="main"

# =============================================================================
# 📂 SYSTEM PATHS
# =============================================================================

# NixOS configuration directory
NIXOS_CONFIG_PATH="/etc/nixos"

# Prefix for automatic mount points
MOUNT_POINT_PREFIX="/mnt"

# Directory for automatic backups
BACKUP_DIR_PREFIX="/etc/nixos.backup"

# =============================================================================
# 👤 DEFAULT CONFIGURATIONS
# =============================================================================

# Default username (used if not specified)
DEFAULT_USERNAME="${USER:-jake}"

# Default hostname (used if not specified)
DEFAULT_HOSTNAME="${HOSTNAME:-nixos}"

# Default user description
DEFAULT_USER_DESCRIPTION="NixOS User"

# =============================================================================
# ⚙️ INSTALLER CONFIGURATIONS
# =============================================================================

# Timeout for network operations (seconds)
NETWORK_TIMEOUT=30

# Maximum retry attempts for operations that may fail
MAX_RETRY_ATTEMPTS=3

# Preset file name
PRESET_FILENAME="preset.conf"

# =============================================================================
# 🌐 LANGUAGE CONFIGURATIONS
# =============================================================================

# Default language (en|pt)
DEFAULT_LANGUAGE="pt"

# Default locale
DEFAULT_LOCALE="pt_BR.UTF-8"

# Default timezone
DEFAULT_TIMEZONE="America/Sao_Paulo"

# =============================================================================
# 🔧 TECHNICAL CONFIGURATIONS
# =============================================================================

# Default mount options for external disks
DEFAULT_MOUNT_OPTIONS="defaults,x-gvfs-show"

# Minimum required free space (MB)
MIN_FREE_SPACE_MB=2048

# =============================================================================
# 📋 CUSTOMIZABLE MESSAGES
# =============================================================================

# Installer title
INSTALLER_TITLE="NixOS Configuration Installer"

# Welcome message
WELCOME_MESSAGE="Bem-vindo ao instalador inteligente do NixOS!"

# Success message
SUCCESS_MESSAGE="Instalação concluída com sucesso!"
