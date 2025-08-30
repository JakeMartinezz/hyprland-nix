#!/usr/bin/env bash

# ========================================
# SCRIPT PÓS-INSTALAÇÃO - Jake Martinez
# ========================================
# 
# Script personalizado executado após rebuild bem-sucedido
# Configura wallpapers, dotfiles e outros ajustes específicos

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Executando configurações pós-instalação do Jake...${NC}"
echo

# ========================================
# CONFIGURAR WALLPAPERS POR MONITOR
# ========================================

echo -e "${BLUE}🖼️  Configurando wallpapers por monitor...${NC}"

# Verificar se dotfiles estão disponíveis
if [[ -d ~/.dotfiles/.wallpapers ]]; then
    echo -e "${GREEN}✅ Wallpapers encontrados em ~/.dotfiles/.wallpapers${NC}"
    
    # Aplicar wallpapers se swww estiver rodando
    if pgrep -x "swww-daemon" > /dev/null; then
        echo -e "${BLUE}   Aplicando wallpapers...${NC}"
        
        # Aplicar wallpaper para cada monitor se conectado
        if hyprctl monitors | grep -q "DP-3"; then
            swww img ~/.dotfiles/.wallpapers/Kiki.jpg --outputs DP-3 --transition-type wipe --transition-duration 1
        fi
        
        if hyprctl monitors | grep -q "DP-4"; then
            swww img ~/.dotfiles/.wallpapers/Glass_Makima.jpg --outputs DP-4 --transition-type wipe --transition-duration 1
        fi
        
        if hyprctl monitors | grep -q "eDP-1"; then
            swww img ~/.dotfiles/.wallpapers/a_girl_with_short_brown_hair_and_white_shirt.jpg --outputs eDP-1 --transition-type wipe --transition-duration 1
        fi
        
        echo -e "${GREEN}✅ Wallpapers aplicados com sucesso!${NC}"
    else
        echo -e "${YELLOW}⚠️  swww-daemon não está rodando, wallpapers serão aplicados no próximo login${NC}"
    fi
    
else
    echo -e "${YELLOW}⚠️  Diretório de wallpapers não encontrado: ~/.dotfiles/.wallpapers${NC}"
fi

# ========================================
# CONFIGURAÇÕES ADICIONAIS
# ========================================

echo -e "${BLUE}🔧 Aplicando configurações adicionais...${NC}"

# Configurar permissões corretas para dotfiles
if [[ -d ~/.dotfiles ]]; then
    echo -e "${BLUE}   Ajustando permissões dos dotfiles...${NC}"
    find ~/.dotfiles -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    echo -e "${GREEN}   • Permissões ajustadas${NC}"
fi

# ========================================
# VERIFICAÇÕES FINAIS
# ========================================

echo -e "${BLUE}🔍 Verificando configurações...${NC}"

# Verificar se hyprland está rodando
if pgrep -x "Hyprland" > /dev/null; then
    echo -e "${GREEN}✅ Hyprland está rodando${NC}"
else
    echo -e "${YELLOW}⚠️  Hyprland não está rodando${NC}"
fi

# Verificar quantidade de monitores conectados
monitor_count=$(hyprctl monitors -j 2>/dev/null | jq length 2>/dev/null || echo "0")
echo -e "${GREEN}✅ Monitores detectados: ${monitor_count}${NC}"

# Verificar se dotfiles estão linkados
if [[ -L ~/.config ]] || [[ -d ~/.dotfiles ]]; then
    echo -e "${GREEN}✅ Dotfiles configurados${NC}"
else
    echo -e "${YELLOW}⚠️  Dotfiles não encontrados${NC}"
fi

# ========================================
# FINALIZAÇÃO
# ========================================

echo
echo -e "${GREEN}✅ Configuração pós-instalação concluída!${NC}"
echo -e "${CYAN}📋 Resumo das configurações aplicadas:${NC}"
echo -e "   • Wallpapers configurados por monitor"
echo -e "   • Permissões de dotfiles ajustadas"
echo -e "   • Sistema verificado e pronto para uso"
echo

# Retornar código de sucesso
exit 0