# Guia de Solução de Problemas 🔧

Este guia ajuda você a resolver problemas comuns encontrados durante a instalação e configuração do sistema NixOS.

## 📋 Índice

1. [Problemas de Instalação](#-problemas-de-instalação)
2. [Problemas de Detecção de Hardware](#-problemas-de-detecção-de-hardware)
3. [Falhas de Rebuild](#-falhas-de-rebuild)
4. [Problemas com Dotfiles](#-problemas-com-dotfiles)
5. [Problemas de Configuração de Discos](#-problemas-de-configuração-de-discos)
6. [Problemas de Rede e Download](#-problemas-de-rede-e-download)
7. [Problemas de Permissão e Acesso](#-problemas-de-permissão-e-acesso)
8. [Problemas de Gerenciamento de Serviços](#-problemas-de-gerenciamento-de-serviços)
9. [Problemas de Scripts de Pós-Instalação](#-problemas-de-scripts-de-pós-instalação)
10. [Problemas de Docker e Containerização](#-problemas-de-docker-e-containerização)
11. [Procedimentos de Rollback e Recuperação](#-procedimentos-de-rollback-e-recuperação)
12. [Debug Avançado](#-debug-avançado)

## 🚀 Problemas de Instalação

### **Script Não Inicia**

#### Problema: "Permission denied" ao executar `./install.sh`
```bash
bash: ./install.sh: Permission denied
```

**Solução:**
```bash
chmod +x install.sh
./install.sh
```

#### Problema: "Este script deve ser executado no NixOS!"
**Causas:**
- Executando em sistema não-NixOS
- Arquivo `/etc/NIXOS` ausente

**Soluções:**
1. Certifique-se que está executando no NixOS
2. Se estiver no NixOS mas arquivo ausente:
   ```bash
   sudo touch /etc/NIXOS
   ```

#### Problema: Dependências ausentes
```bash
❌ Dependências ausentes: git, curl, base64
```

**Solução:**
```bash
# Instalar dependências ausentes
nix-shell -p git curl coreutils
# Depois executar o instalador
./install.sh
```

#### Problema: Falhas nas verificações de segurança
**Sintomas:** Instalador sai durante validação de segurança

**Problemas Comuns:**
1. **Executando como root:**
   ```bash
   ❌ ERRO: Não execute este instalador como root!
   ```
   **Solução:** Execute como usuário normal: `./install.sh`

2. **Sem conexão com internet:**
   ```bash
   ❌ ERRO: Sem conexão com internet
   ```
   **Solução:** Verificar conectividade de rede e DNS

3. **Local de execução inválido:**
   ```bash
   ❌ ERRO: Não execute este script dentro de /etc/nixos!
   ```
   **Solução:** Execute do diretório home ou Downloads

```bash
# Instalar dependências ausentes
nix-shell -p git curl coreutils
# Então executar o instalador
./install.sh
```

### **Coleta de Configuração Falha**

#### Problema: Detecção de GPU inválida
**Sintomas:** Script detecta GPU errada ou falha na detecção

**Soluções:**
1. **Substituição Manual:** Escolha tipo de GPU diferente quando solicitado
2. **Verificar Hardware:**
   ```bash
   lspci | grep -i vga
   lshw -c display
   ```
3. **Forçar Detecção:**
   ```bash
   # Editar variables.nix manualmente após instalação
   sudo nano /etc/nixos/config/variables.nix
   ```

#### Problema: Validação de hostname/username falha
**Sintomas:** Script rejeita hostnames ou usernames válidos

**Soluções:**
1. **Use Nomes Simples:** Evite caracteres especiais, use apenas alfanuméricos
2. **Verificar Comprimento:** Mantenha abaixo de 63 caracteres
3. **Exemplos Válidos:**
   - ✅ `jake`, `martinez`, `desktop-01`
   - ❌ `user@domain`, `desktop_com_espacos`, `123numerico`

## 🔧 Problemas de Detecção de Hardware

### **Problemas com GPU**

#### Problema: Drivers NVIDIA não carregam após instalação
**Sintomas:**
- Tela preta após reinicialização
- `nvidia-smi` não encontrado
- Problemas de performance gráfica

**Soluções:**
1. **Verificar Configuração:**
   ```bash
   cat /etc/nixos/config/variables.nix | grep -A 5 gpu
   ```

2. **Verificar Instalação:**
   ```bash
   lsmod | grep nvidia
   systemctl status display-manager
   ```

3. **Correção Manual:**
   ```bash
   # Editar variables.nix
   sudo nano /etc/nixos/config/variables.nix
   
   # Definir tipo correto de GPU
   gpu = {
     type = "nvidia";  # ou "amd" ou "intel"
     nvidia.enable = true;
   };
   
   # Rebuild
   sudo nixos-rebuild switch --flake /etc/nixos#default
   ```

#### Problema: Problemas de performance com GPU AMD
**Sintomas:**
- Performance gráfica ruim
- Jogos executando lentamente
- Erros de driver nos logs

**Soluções:**
1. **Verificar Carregamento do Driver:**
   ```bash
   lsmod | grep amdgpu
   dmesg | grep amdgpu
   ```

2. **Atualizar Configuração:**
   ```bash
   # Garantir que drivers AMD estão configurados corretamente
   sudo nano /etc/nixos/config/variables.nix
   ```

### **Problemas de Detecção de Disco**

#### Problema: Discos adicionais não detectados
**Sintomas:** Script mostra "Nenhum disco adicional detectado"

**Soluções:**
1. **Verificar Status do Disco:**
   ```bash
   lsblk -f
   sudo fdisk -l
   ```

2. **Executar com Privilégios Elevados:**
   ```bash
   sudo ./install.sh
   ```

3. **Configuração Manual de Disco:**
   ```bash
   # Encontrar UUID do disco
   blkid /dev/sdb1
   
   # Editar variables.nix após instalação
   sudo nano /etc/nixos/config/variables.nix
   ```

#### Problema: Conflitos de ponto de montagem
**Sintomas:** Montagem de disco falha com "target is busy"

**Soluções:**
1. **Verificar Montagens Atuais:**
   ```bash
   mount | grep /mnt
   findmnt /mnt/seudisco
   ```

2. **Desmontar Antes da Reconfiguração:**
   ```bash
   sudo umount /mnt/seudisco
   sudo nixos-rebuild switch --flake /etc/nixos#default
   ```

## 🔄 Falhas de Rebuild

### **Erros Comuns de Rebuild**

#### Problema: "evaluation aborted with the following error message"
**Sintomas:** Avaliação Nix falha durante rebuild

**Soluções:**
1. **Verificar Sintaxe:**
   ```bash
   # Validar sintaxe Nix
   nix-instantiate --parse /etc/nixos/config/variables.nix
   ```

2. **Verificar Chaves e Ponto-e-vírgulas:**
   ```bash
   # Problemas comuns: ponto-e-vírgulas ausentes, chaves não correspondentes
   sudo nano /etc/nixos/config/variables.nix
   ```

3. **Restaurar do Backup:**
   ```bash
   sudo nixos-rebuild --rollback
   ```

#### Problema: "file 'nixpkgs' was not found"
**Sintomas:** Problemas de entrada de flake

**Soluções:**
1. **Atualizar Lock do Flake:**
   ```bash
   cd /etc/nixos
   sudo nix flake update
   sudo nixos-rebuild switch --flake .#default
   ```

2. **Verificar Conexão com Internet:**
   ```bash
   ping github.com
   nix-channel --update
   ```

#### Problema: Falhas de build devido a espaço em disco
**Sintomas:** "No space left on device"

**Soluções:**
1. **Limpar Nix Store:**
   ```bash
   sudo nix-collect-garbage -d
   sudo nix-store --optimise
   ```

2. **Verificar Espaço Disponível:**
   ```bash
   df -h /nix
   du -sh /nix/store
   ```

3. **Mover Nix Store (Avançado):**
   ```bash
   # Apenas se você tiver outro disco com mais espaço
   # Isso requer conhecimento avançado
   ```

### **Falhas de Inicialização de Serviços**

#### Problema: Serviços falham ao iniciar após rebuild
**Sintomas:** Serviços SystemD em estado falho

**Soluções:**
1. **Verificar Status do Serviço:**
   ```bash
   systemctl --failed
   systemctl status nome-do-servico
   journalctl -u nome-do-servico -f
   ```

2. **Correções Comuns de Serviços:**
   ```bash
   # Problemas de display manager
   systemctl restart display-manager
   
   # Problemas de rede
   systemctl restart NetworkManager
   
   # Problemas de áudio
   systemctl --user restart pipewire
   ```

## 📁 Problemas com Dotfiles

### **Problemas com Stow**

#### Problema: "No stowable packages found"
**Sintomas:** Aplicação de dotfiles falha

**Soluções:**
1. **Verificar Estrutura de Dotfiles:**
   ```bash
   ls -la ~/.dotfiles/
   tree ~/.dotfiles/  # se disponível
   ```

2. **Corrigir Estrutura para Modo de Pacotes:**
   ```bash
   cd ~/.dotfiles
   mkdir config zsh
   mv .config config/
   mv .zshrc zsh/
   stow */
   ```

3. **Corrigir para Modo Direto:**
   ```bash
   cd ~/.dotfiles
   stow .
   ```

#### Problema: Conflitos do Stow
**Sintomas:** "WARNING! stowing would cause conflicts"

**Soluções:**
1. **Verificar Conflitos:**
   ```bash
   cd ~/.dotfiles
   stow --no-folding --verbose .
   ```

2. **Remover Arquivos Conflitantes:**
   ```bash
   # Fazer backup de arquivos existentes
   mv ~/.arquivo_existente ~/.arquivo_existente.backup
   stow .
   ```

3. **Forçar Sobrescrita (Cuidado!):**
   ```bash
   stow --adopt .  # Adota arquivos existentes no stow
   ```

### **Problemas de Instalação do GNU Stow**

#### Problema: "GNU Stow não encontrado"
**Soluções:**
```bash
# Instalar stow no sistema
nix-env -iA nixpkgs.stow

# Ou usar nix-shell
nix-shell -p stow --run "stow ."
```

## 💾 Problemas de Configuração de Discos

### **Problemas com UUID**

#### Problema: "UUID não encontrado" após reinicialização
**Sintomas:** Montagem de disco falha na inicialização

**Soluções:**
1. **Verificar UUID:**
   ```bash
   blkid | grep nome-do-seu-disco
   ```

2. **Atualizar Configuração:**
   ```bash
   sudo nano /etc/nixos/config/variables.nix
   # Atualizar o UUID na seção filesystems
   ```

3. **Regenerar Configuração de Hardware:**
   ```bash
   sudo nixos-generate-config
   sudo nixos-rebuild switch --flake /etc/nixos#default
   ```

### **Problemas de Sistema de Arquivos**

#### Problema: "Bad filesystem type" durante montagem
**Soluções:**
1. **Verificar Sistema de Arquivos:**
   ```bash
   file -s /dev/seu-disco
   lsblk -f
   ```

2. **Formatar se Necessário:**
   ```bash
   # CUIDADO: Isso apagará dados!
   sudo mkfs.ext4 /dev/seu-disco
   ```

3. **Atualizar Configuração:**
   ```bash
   # Combinar fsType em variables.nix com sistema de arquivos real
   fsType = "ext4";  # ou "btrfs", "xfs", etc.
   ```

## 🌐 Problemas de Rede e Download

### **Falhas de Download**

#### Problema: Erros "Failed to download" durante rebuild
**Soluções:**
1. **Verificar Conexão com Internet:**
   ```bash
   ping nixos.org
   ping github.com
   ```

2. **Verificar DNS:**
   ```bash
   nslookup github.com
   # Se falhar, tentar DNS diferente
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

3. **Usar Cache Binário Diferente:**
   ```bash
   # Adicionar ao configuration.nix
   nix.settings.substituters = [ "https://cache.nixos.org/" ];
   ```

### **Problemas de Proxy**

#### Problema: Atrás de firewall corporativo/proxy
**Soluções:**
```bash
# Definir variáveis de ambiente de proxy
export http_proxy=http://proxy.empresa.com:8080
export https_proxy=http://proxy.empresa.com:8080
export no_proxy=localhost,127.0.0.1

# Configurar Nix
nix-env --option http-proxy http://proxy.empresa.com:8080
```

## 🔐 Problemas de Permissão e Acesso

### **Problemas com Sudo/Root**

#### Problema: "sudo: command not found" ou permissão negada
**Soluções:**
1. **Verificar Instalação do sudo:**
   ```bash
   which sudo
   su -c "nixos-rebuild switch --flake /etc/nixos#default"
   ```

2. **Adicionar Usuário ao Grupo wheel:**
   ```bash
   sudo usermod -aG wheel nomeusuario
   # Ou editar configuração manualmente
   ```

### **Problemas de Permissão de Arquivo**

#### Problema: Não é possível escrever em `/etc/nixos`
**Soluções:**
```bash
# Verificar ownership
ls -la /etc/nixos/

# Corrigir ownership
sudo chown -R root:root /etc/nixos
sudo chmod 755 /etc/nixos
```

## 🔧 Problemas de Scripts de Pós-Instalação

### **Problemas de Execução de Script**

#### Problema: Script de pós-instalação não detectado
**Sintomas:** Instalador pula diretamente para prompt de limpeza, sem mensagem de detecção de script

**Soluções:**
1. **Verificar Localização do Script:**
   ```bash
   ls -la post-install.sh
   # Deve estar no mesmo diretório que install.sh
   ```

2. **Verificar Nome do Arquivo:**
   ```bash
   # Deve ser exatamente "post-install.sh" (sensível a maiúsculas/minúsculas)
   mv post_install.sh post-install.sh  # Se usando underscores
   mv Post-Install.sh post-install.sh  # Se usando maiúsculas
   ```

3. **Verificar Diretório de Trabalho:**
   ```bash
   pwd  # Deve estar no diretório do instalador
   ./install.sh  # Executar da localização correta
   ```

#### Problema: "Permission denied" ao executar script
**Sintomas:** Script é detectado mas falha ao executar com erros de permissão

**Soluções:**
1. **Verificar Permissões do Script:**
   ```bash
   ls -la post-install.sh
   # Deve mostrar permissões de execução (x) para o usuário
   ```

2. **Corrigir Permissões:**
   ```bash
   chmod +x post-install.sh
   # O instalador deveria fazer isso automaticamente, mas correção manual funciona
   ```

3. **Verificar Propriedade do Script:**
   ```bash
   # Garantir que você é proprietário do script
   sudo chown $USER:$USER post-install.sh
   ```

#### Problema: Script executa mas comandos falham
**Sintomas:** Script roda mas comandos individuais dentro dele falham

**Soluções:**
1. **Testar Comandos Manualmente:**
   ```bash
   # Testar cada comando do seu script individualmente
   swww img ~/.dotfiles/.wallpapers/test.jpg --outputs DP-3
   hyprctl monitors
   ```

2. **Verificar Dependências:**
   ```bash
   # Verificar se ferramentas necessárias estão disponíveis
   which swww
   which hyprctl
   which pgrep
   
   # Verificar se serviços estão executando
   pgrep -x "swww-daemon"
   pgrep -x "Hyprland"
   ```

3. **Adicionar Verificação de Erros:**
   ```bash
   #!/bin/bash
   # Adicionar ao seu post-install.sh
   
   # Sair em erro (opcional, para depuração)
   set -e
   
   # Verificar se comando existe antes de usar
   if ! command -v swww >/dev/null 2>&1; then
       echo -e "${YELLOW}⚠️ SWWW não encontrado, pulando configuração de wallpaper${NC}"
       exit 0
   fi
   ```

### **Problemas Comuns de Script**

#### Problema: Comandos de wallpaper não funcionam
**Sintomas:** Comandos SWWW no script falham ou não aplicam wallpapers

**Soluções:**
1. **Verificar Daemon SWWW:**
   ```bash
   # Verificar se daemon está executando
   pgrep -x "swww-daemon"
   
   # Iniciar daemon se não estiver executando
   swww init
   ```

2. **Testar Comando de Wallpaper:**
   ```bash
   # Testar aplicação de wallpaper manualmente
   swww img /caminho/para/wallpaper.jpg --outputs DP-3
   
   # Verificar monitores disponíveis
   hyprctl monitors
   ```

3. **Corrigir Caminhos de Arquivo:**
   ```bash
   # Garantir que arquivos de wallpaper existem
   ls -la ~/.dotfiles/.wallpapers/
   
   # Usar caminhos absolutos no script
   swww img /home/$USER/.dotfiles/.wallpapers/wallpaper.jpg
   ```

#### Problema: Detecção de monitor não funciona
**Sintomas:** Script não consegue detectar monitores conectados

**Soluções:**
1. **Verificar Status do Hyprland:**
   ```bash
   # Verificar se Hyprland está executando
   echo $XDG_SESSION_TYPE  # Deve mostrar "wayland"
   hyprctl version
   ```

2. **Testar Comandos de Monitor:**
   ```bash
   # Listar monitores
   hyprctl monitors
   
   # Verificar monitor específico
   hyprctl monitors | grep -q "DP-3" && echo "DP-3 conectado"
   ```

3. **Corrigir Nomes de Monitor:**
   ```bash
   # Obter nomes reais dos monitores
   hyprctl monitors -j | jq -r '.[] | .name'
   
   # Atualizar script com nomes corretos
   if hyprctl monitors | grep -q "HDMI-1"; then  # Em vez de DP-3
   ```

#### Problema: Problemas de formatação de saída do script
**Sintomas:** Códigos de cor ou formatação não exibem corretamente

**Soluções:**
1. **Verificar Suporte do Terminal:**
   ```bash
   # Testar suporte de cor
   echo -e "\033[32mTexto Verde de Teste\033[0m"
   
   # Verificar variável TERM
   echo $TERM
   ```

2. **Corrigir Definições de Cor:**
   ```bash
   # Garantir que variáveis de cor estão definidas corretamente
   RED='\033[0;31m'
   GREEN='\033[0;32m'
   BLUE='\033[0;34m'
   YELLOW='\033[1;33m'
   NC='\033[0m' # Sem Cor (importante para reset)
   ```

3. **Usar Printf em Vez de Echo:**
   ```bash
   # Mais confiável que echo -e
   printf "${GREEN}✅ Mensagem de sucesso${NC}\n"
   ```

### **Depuração de Scripts**

#### Problema: Preciso depurar execução de script
**Soluções:**
1. **Ativar Modo Debug:**
   ```bash
   # Adicionar ao topo do post-install.sh para saída detalhada
   #!/bin/bash
   set -x  # Mostrar cada comando conforme é executado
   set -e  # Sair no primeiro erro (opcional)
   ```

2. **Adicionar Logging:**
   ```bash
   # Adicionar logging ao seu script
   LOG_FILE="/tmp/post-install.log"
   echo "$(date): Iniciando script pós-instalação" >> $LOG_FILE
   
   # Log de comandos
   swww img wallpaper.jpg 2>&1 | tee -a $LOG_FILE
   ```

3. **Testar Script Independentemente:**
   ```bash
   # Testar script fora do instalador
   bash -n post-install.sh  # Verificar sintaxe
   bash -x post-install.sh  # Executar com saída de debug
   ```

#### Problema: Script funciona manualmente mas falha durante instalador
**Sintomas:** Script executa bem quando executado diretamente mas falha durante instalação

**Soluções:**
1. **Verificar Diferenças de Ambiente:**
   ```bash
   # Comparar variáveis de ambiente
   env | sort > manual_env.txt  # Quando executado manualmente
   # Então verificar durante execução do instalador
   ```

2. **Verificar Diretório de Trabalho:**
   ```bash
   # Adicionar ao script para verificar diretório atual
   echo "Diretório atual: $(pwd)"
   echo "Localização do script: $(dirname "$0")"
   ```

3. **Usar Caminhos Absolutos:**
   ```bash
   # Usar caminhos completos em vez de relativos
   HOME_DIR="/home/$USER"
   swww img "$HOME_DIR/.dotfiles/.wallpapers/wallpaper.jpg"
   ```

### **Melhores Práticas para Solução de Problemas de Scripts**

#### Criar um Script Post-Install Robusto:
```bash
#!/bin/bash
# Template robusto de post-install.sh

# Definições de cores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função de tratamento de erro
handle_error() {
    echo -e "${RED}❌ Erro: $1${NC}" >&2
    exit 1
}

# Função de verificação de dependência
check_dependency() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ $1 não encontrado, pulando tarefas relacionadas${NC}"
        return 1
    fi
    return 0
}

# Script principal
echo -e "${GREEN}🔧 Iniciando configuração pós-instalação...${NC}"

# Verificar se estamos no ambiente correto
if [ -z "$XDG_SESSION_TYPE" ] || [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo -e "${YELLOW}⚠️ Não em sessão Wayland, alguns recursos podem não funcionar${NC}"
fi

# Configuração de wallpaper (com tratamento de erro)
if check_dependency "swww" && check_dependency "hyprctl"; then
    if pgrep -x "swww-daemon" >/dev/null; then
        echo -e "${BLUE}   Configurando wallpapers...${NC}"
        
        # Definir diretório de wallpaper
        WALLPAPER_DIR="$HOME/.dotfiles/.wallpapers"
        
        # Verificar se diretório de wallpaper existe
        if [ ! -d "$WALLPAPER_DIR" ]; then
            echo -e "${YELLOW}⚠️ Diretório de wallpaper não encontrado: $WALLPAPER_DIR${NC}"
        else
            # Aplicar wallpapers para monitores conectados
            if hyprctl monitors | grep -q "DP-3" && [ -f "$WALLPAPER_DIR/Kiki.jpg" ]; then
                swww img "$WALLPAPER_DIR/Kiki.jpg" --outputs DP-3 --transition-type wipe --transition-duration 1 || \
                    echo -e "${YELLOW}⚠️ Falha ao definir wallpaper para DP-3${NC}"
            fi
            
            if hyprctl monitors | grep -q "DP-4" && [ -f "$WALLPAPER_DIR/Glass_Makima.jpg" ]; then
                swww img "$WALLPAPER_DIR/Glass_Makima.jpg" --outputs DP-4 --transition-type wipe --transition-duration 1 || \
                    echo -e "${YELLOW}⚠️ Falha ao definir wallpaper para DP-4${NC}"
            fi
            
            echo -e "${GREEN}✅ Configuração de wallpaper concluída${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Daemon SWWW não está executando, pulando configuração de wallpaper${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Ferramentas necessárias não disponíveis, pulando configuração de wallpaper${NC}"
fi

echo -e "${GREEN}🎉 Configuração pós-instalação finalizada!${NC}"
```

#### Comandos Rápidos de Depuração:
```bash
# Verificar sintaxe do script sem execução
bash -n post-install.sh

# Executar script com saída verbose
bash -x post-install.sh

# Verificar se script é executável
ls -la post-install.sh

# Testar componentes individuais
hyprctl monitors | grep -q "DP-3" && echo "Monitor DP-3 encontrado"
pgrep -x "swww-daemon" && echo "Daemon SWWW executando"
```

## 🐳 Problemas de Docker e Containerização

### **Problemas de Serviço Docker**

#### Problema: Serviço Docker não inicia
**Sintomas:** 
- Comando `docker ps` falha
- Erros "Cannot connect to Docker daemon"
- Serviço falha ao iniciar automaticamente

**Soluções:**
1. **Verificar Status do Serviço Docker:**
   ```bash
   systemctl status docker
   systemctl --user status docker  # Para modo rootless
   ```

2. **Iniciar Serviço Docker:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Verificar Permissões do Usuário:**
   ```bash
   # Adicionar usuário ao grupo docker
   sudo usermod -aG docker $USER
   # Fazer logout e login novamente para mudanças terem efeito
   ```

4. **Para Docker Rootless:**
   ```bash
   # Verificar configuração rootless
   systemctl --user status docker
   export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
   ```

#### Problema: Containers Docker não iniciam
**Sintomas:**
- Containers saem imediatamente
- Erros "No such file or directory"
- Erros de permissão negada

**Soluções:**
1. **Verificar Logs do Container:**
   ```bash
   docker logs nome-container
   docker inspect nome-container
   ```

2. **Verificar Recursos do Sistema:**
   ```bash
   df -h  # Espaço em disco
   free -h  # Memória
   ```

3. **Reiniciar Serviço Docker:**
   ```bash
   sudo systemctl restart docker
   ```

### **Problemas com Portainer**

#### Problema: Container Portainer não inicia
**Sintomas:**
- Não é possível acessar interface web Portainer em localhost:9000
- Status do serviço Portainer falhou
- Conflitos de binding de porta

**Soluções:**
1. **Verificar Status do Serviço Portainer:**
   ```bash
   systemctl status portainer
   journalctl -u portainer -f
   ```

2. **Verificar Disponibilidade de Porta:**
   ```bash
   netstat -tulpn | grep :9000
   netstat -tulpn | grep :9443
   ```

3. **Inicialização Manual do Portainer:**
   ```bash
   # Parar serviço primeiro
   sudo systemctl stop portainer
   
   # Remover container existente
   docker stop portainer 2>/dev/null || true
   docker rm portainer 2>/dev/null || true
   
   # Iniciar manualmente para verificar erros
   docker run -d \
     --name portainer \
     --restart=always \
     -p 9000:9000 \
     -p 9443:9443 \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v portainer_data:/data \
     portainer/portainer-ce:latest
   ```

4. **Verificar Firewall:**
   ```bash
   # Verificar se portas do firewall estão abertas
   sudo iptables -L | grep -E "(9000|9443)"
   ```

#### Problema: Não é possível acessar interface web Portainer
**Soluções:**
1. **Verificar Status do Serviço:**
   ```bash
   docker ps | grep portainer
   curl -I http://localhost:9000
   ```

2. **Verificar Configuração de Rede:**
   ```bash
   # Testar binding de porta
   netstat -tulpn | grep portainer
   ss -tulpn | grep :9000
   ```

3. **Problemas de Acesso do Navegador:**
   - Tente `http://localhost:9000` em vez de `127.0.0.1:9000`
   - Limpe cache e cookies do navegador
   - Tente navegador diferente ou modo incógnito
   - Verifique console do navegador para erros JavaScript

### **Problemas de Build Docker**

#### Problema: Builds Docker falham com erros de permissão
**Soluções:**
1. **Verificar Configurações do BuildKit:**
   ```bash
   # Verificar se BuildKit está habilitado
   echo $DOCKER_BUILDKIT
   docker buildx version
   ```

2. **Corrigir Permissões de Arquivo:**
   ```bash
   # No diretório do Dockerfile
   chmod +r Dockerfile
   sudo chown -R $USER:$USER .
   ```

3. **Usar Buildx para Builds Complexos:**
   ```bash
   docker buildx build --platform linux/amd64 -t meuapp .
   ```

#### Problema: Falta de espaço em disco durante builds
**Soluções:**
1. **Limpar Sistema Docker:**
   ```bash
   # Remover dados não utilizados (automático com auto-prune habilitado)
   docker system prune -af
   
   # Verificar uso de disco
   docker system df
   ```

2. **Verificar Configuração Auto-Prune:**
   ```bash
   # Verificar se auto-prune está funcionando
   systemctl list-timers | grep docker-prune
   journalctl -u docker-prune --since="1 week ago"
   ```

### **Problemas de Rede Docker**

#### Problema: Containers não conseguem acessar internet
**Soluções:**
1. **Verificar Rede Docker:**
   ```bash
   docker network ls
   docker network inspect bridge
   ```

2. **Verificar Rede do Sistema:**
   ```bash
   # Verificar resolução DNS
   docker run --rm busybox nslookup google.com
   
   # Verificar roteamento
   ip route show
   ```

3. **Reiniciar Serviços de Rede:**
   ```bash
   sudo systemctl restart NetworkManager
   sudo systemctl restart docker
   ```

#### Problema: Conflitos de porta entre containers
**Soluções:**
1. **Verificar Uso de Porta:**
   ```bash
   netstat -tulpn | grep :NUMERO_PORTA
   docker ps --format "table {{.Names}}\t{{.Ports}}"
   ```

2. **Usar Portas Diferentes:**
   ```bash
   # Mapear para porta diferente do host
   docker run -p 8080:80 nginx  # Em vez de 80:80
   ```

3. **Usar Redes Docker:**
   ```bash
   # Criar rede personalizada
   docker network create minharede
   docker run --network minharede meuapp
   ```

### **Problemas com Docker Compose**

#### Problema: Serviços Docker Compose falham ao iniciar
**Soluções:**
1. **Verificar Sintaxe do Compose:**
   ```bash
   docker-compose config
   docker-compose validate
   ```

2. **Verificar Dependências de Serviços:**
   ```bash
   # Iniciar serviços individualmente
   docker-compose up nome-servico
   
   # Verificar logs
   docker-compose logs nome-servico
   ```

3. **Atualizar Arquivo Compose:**
   ```bash
   # Usar versão compatível
   version: '3.8'  # Em vez de versões mais novas
   ```

### **Problemas de Armazenamento Docker**

#### Problema: Falhas de montagem de volume
**Soluções:**
1. **Verificar Permissões de Volume:**
   ```bash
   # Criar volume com permissões corretas
   docker volume create --driver local meuvolume
   
   # Verificar volumes existentes
   docker volume ls
   docker volume inspect meuvolume
   ```

2. **Corrigir Permissões de Montagem Host:**
   ```bash
   # Para montagens de volume host
   sudo chmod 755 /caminho/host
   sudo chown -R 1000:1000 /caminho/host  # Combinar com usuário do container
   ```

#### Problema: Dados do container não persistem
**Soluções:**
1. **Verificar Configuração de Volume:**
   ```bash
   # Verificar se volume está montado corretamente
   docker inspect nome-container | grep -A 10 "Mounts"
   ```

2. **Usar Volumes Nomeados:**
   ```bash
   # Em vez de volumes anônimos
   docker run -v meusdados:/app/data meuapp
   ```

## 🚨 Procedimentos de Recuperação

### **Sistema Não Inicializa**

#### Passos de Recuperação de Emergência:
1. **Inicializar do ISO NixOS**
2. **Montar Sistema:**
   ```bash
   sudo mount /dev/nvme0n1p2 /mnt  # Substituir pela sua partição root
   sudo mount /dev/nvme0n1p1 /mnt/boot  # Substituir pela sua partição boot
   ```

3. **Chroot no Sistema:**
   ```bash
   sudo nixos-enter --root /mnt
   ```

4. **Rollback da Configuração:**
   ```bash
   nixos-rebuild --rollback
   # Ou listar gerações e escolher
   nix-env --list-generations --profile /nix/var/nix/profiles/system
   nixos-rebuild switch --rollback-generation 123
   ```

### **Restaurar do Backup**

#### Se Instalação Criou Backup:
```bash
# Localização do backup (geralmente mostrada durante instalação)
ls ~/nixos-backup-*

# Restaurar backup
sudo rm -rf /etc/nixos/*
sudo cp -r ~/nixos-backup-*/* /etc/nixos/
sudo nixos-rebuild switch
```

### **Reset Completo**

#### Começar do Zero com Instalação Limpa:
```bash
# Salvar dados importantes primeiro!
cp -r ~/.config ~/config-backup
cp -r ~/.dotfiles ~/dotfiles-backup

# Remover configuração
sudo rm -rf /etc/nixos/*

# Regerar configuração básica
sudo nixos-generate-config

# Executar instalador novamente
cd ~/nixos  # ou onde você tem o instalador
./install.sh
```

## 🔍 Debug Avançado

### **Ativar Saída Verbose**

#### Debug de Problemas de Build Nix:
```bash
# Rebuild verbose
sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace --verbose

# Debug de derivação específica
nix build --show-trace /etc/nixos#nixosConfigurations.default.config.system.build.toplevel
```

#### Debug de Problemas de Script:
```bash
# Executar instalador com debug bash
bash -x ./install.sh

# Ou adicionar ao script temporariamente
set -x  # Ativar debugging
set +x  # Desativar debugging
```

### **Análise de Logs**

#### Logs do Sistema:
```bash
# Problemas recentes do sistema
journalctl --priority=err --since="1 hour ago"

# Logs de serviço específico
journalctl -u display-manager -f
journalctl -u NetworkManager -f

# Problemas de boot
journalctl -b -1 --priority=err  # Boot anterior
```

#### Logs do Nix:
```bash
# Logs do daemon nix
journalctl -u nix-daemon -f

# Localização dos logs de build
ls /nix/var/log/nix/drvs/
```

### **Debug de Hardware**

#### Problemas de GPU:
```bash
# Verificar detecção de hardware
lspci -nn | grep -E "(VGA|3D)"
lshw -c display

# Verificar drivers carregados
lsmod | grep -E "nvidia|amdgpu|i915"

# Verificar logs do Xorg
journalctl -u display-manager
cat /var/log/X.0.log
```

#### Problemas de Áudio:
```bash
# Verificar hardware de áudio
aplay -l
pactl list sinks

# Verificar status do PipeWire
systemctl --user status pipewire
```

## 📞 Obtendo Ajuda

### **Antes de Pedir Ajuda**

1. **Coletar Informações:**
   ```bash
   # Info do sistema
   nixos-version
   uname -a
   
   # Info de hardware
   lscpu
   lspci
   lsblk -f
   
   # Info de configuração
   cat /etc/nixos/config/variables.nix
   ```

2. **Verificar Logs:**
   ```bash
   # Erros recentes
   journalctl --priority=err --since="1 hour ago" --no-pager
   
   # Logs de build Nix
   journalctl -u nix-daemon --since="1 hour ago" --no-pager
   ```

3. **Criar Reprodução Mínima:**
   - Documentar passos exatos que causam o problema
   - Anotar mensagens de erro verbatim
   - Incluir especificações do sistema

### **Onde Obter Ajuda**

- **GitHub Issues**: Reportar bugs e solicitar recursos
- **NixOS Discourse**: Suporte da comunidade e discussões
- **NixOS Wiki**: Documentação e guias
- **Matrix/Discord**: Chat da comunidade em tempo real

### **Informações a Incluir**

1. **Informações do Sistema:**
   - Versão do NixOS
   - Especificações de hardware
   - Método de instalação usado

2. **Descrição do Problema:**
   - O que você estava tentando fazer
   - O que aconteceu em vez disso
   - Mensagens de erro completas

3. **Configuração:**
   - Partes relevantes de `variables.nix`
   - Quaisquer modificações personalizadas
   - Detalhes de configuração de hardware

---

**Lembre-se**: A maioria dos problemas tem soluções simples. Comece com os passos básicos de solução de problemas antes de tentar procedimentos avançados de recuperação. Sempre faça backup de dados importantes antes de fazer mudanças significativas na configuração do seu sistema.