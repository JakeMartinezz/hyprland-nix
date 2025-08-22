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
9. [Procedimentos de Rollback e Recuperação](#-procedimentos-de-rollback-e-recuperação)
10. [Debug Avançado](#-debug-avançado)

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
1. **Ativar Modo Gaming:**
   ```bash
   gaming-mode-on
   ```

2. **Verificar Carregamento do Driver:**
   ```bash
   lsmod | grep amdgpu
   dmesg | grep amdgpu
   ```

3. **Atualizar Configuração:**
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