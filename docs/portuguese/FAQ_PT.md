# Perguntas Frequentes 🤔

Perguntas e respostas comuns sobre o Instalador de Configuração NixOS e configuração.

## 📋 Índice

1. [Perguntas Gerais](#-perguntas-gerais)
2. [Perguntas sobre Instalação](#-perguntas-sobre-instalação)
3. [Perguntas sobre Configuração](#-perguntas-sobre-configuração)
4. [Compatibilidade de Hardware](#-compatibilidade-de-hardware)
5. [Sistema de Feature Flags](#-sistema-de-feature-flags)
6. [Integração de Dotfiles](#-integração-de-dotfiles)
7. [Performance e Gaming](#-performance-e-gaming)
8. [Solução de Problemas](#-solução-de-problemas)
9. [Uso Avançado](#-uso-avançado)
10. [Comparação com Outras Configurações](#-comparação-com-outras-configurações)

## 🌟 Perguntas Gerais

### **P: O que é esta configuração NixOS?**
**R:** Esta é uma configuração NixOS modular, baseada em feature flags, que fornece um ambiente desktop completo com Hyprland. É projetada para ser universal - uma configuração que se adapta a qualquer hardware através de variáveis centralizadas e flags booleanos.

### **P: Para quem é esta configuração?**
**R:** Perfeita para:
- **Entusiastas de gaming** que querem performance otimizada
- **Desenvolvedores** que precisam de um ambiente de desenvolvimento completo
- **Power users** que querem um sistema customizável e reproduzível
- **Qualquer pessoa** que queira uma configuração NixOS moderna sem configuração manual

### **P: O que torna esta configuração diferente de outras configurações NixOS?**
**R:** Principais diferenças:
- **Design Universal**: Uma config se adapta a qualquer hardware via feature flags
- **Instalador Inteligente**: Configuração interativa com detecção de hardware
- **Foco em Gaming**: Otimizações e scripts de gaming integrados
- **Multilíngue**: Suporte completo em português e inglês
- **Gerenciamento Inteligente de Discos**: Detecção e montagem automática de discos adicionais

### **P: Esta configuração é amigável para iniciantes?**
**R:** Sim! O instalador interativo te guia através de:
- Detecção automática de hardware
- Configuração passo a passo
- Explicações claras para cada opção
- Instalação segura com opções de backup
- Documentação abrangente

## 🚀 Perguntas sobre Instalação

### **P: Quais são os requisitos do sistema?**
**R:** Requisitos mínimos:
- **OS**: NixOS (ISO do instalador ou instalação existente)
- **RAM**: 4GB (8GB+ recomendado)
- **Armazenamento**: 20GB de espaço livre (40GB+ recomendado)
- **Arquitetura**: x86_64
- **Internet**: Necessária para download de pacotes

### **P: Posso instalar isto em um sistema NixOS existente?**
**R:** Sim! O instalador:
- Oferece fazer backup da sua configuração existente
- Preserva seu `hardware-configuration.nix`
- Permite revisar mudanças antes de aplicar
- Fornece opções de rollback se algo der errado

### **P: Quanto tempo demora a instalação?**
**R:** O tempo de instalação varia:
- **Configuração**: 5-10 minutos (configuração interativa)
- **Cópia de arquivos**: 1-2 minutos
- **Rebuild**: 15-45 minutos (dependendo dos recursos habilitados e velocidade da internet)
- **Total**: 20-60 minutos para configuração completa

### **P: Posso executar este instalador várias vezes?**
**R:** Absolutamente! O instalador:
- Salva sua configuração como presets para reuso rápido
- Detecta instalações existentes e oferece atualizações
- Permite modificar recursos sem começar do zero
- Preserva suas customizações entre execuções

### **P: E se a instalação falhar?**
**R:** O instalador é projetado para segurança:
- Cria backups antes de fazer mudanças
- Fornece mensagens de erro detalhadas
- Oferece opções de rollback
- Tem documentação abrangente de solução de problemas
- Veja [TROUBLESHOOTING.md](TROUBLESHOOTING.md) para soluções específicas

## ⚙️ Perguntas sobre Configuração

### **P: Onde a configuração principal é armazenada?**
**R:** Localizações principais:
- **Feature Flags**: `/etc/nixos/config/variables.nix` (configuração central)
- **Config do Sistema**: `/etc/nixos/configuration.nix`
- **Config Home**: `/etc/nixos/home.nix`
- **Módulos**: `/etc/nixos/modules/` (organizados por tipo)

### **P: Como modifico a configuração após a instalação?**
**R:** Várias opções:
1. **Editar variables.nix**: `sudo nano /etc/nixos/config/variables.nix`
2. **Executar instalador novamente**: Re-executar `./install.sh` para modificar recursos
3. **Edição manual**: Editar arquivos de módulos específicos conforme necessário
4. **Usar comando rebuild**: `rebuild` após fazer mudanças

### **P: Posso desabilitar recursos que não preciso?**
**R:** Sim! Edite `/etc/nixos/config/variables.nix`:
```nix
features = {
  gaming.enable = false;        # Desabilitar pacotes de gaming
  development.enable = false;   # Desabilitar ferramentas de dev
  media.enable = false;         # Desabilitar aplicações de mídia
  services.virtualbox.enable = false;  # Desabilitar VirtualBox
};
```
Então execute: `rebuild`

### **P: Como adiciono meus próprios pacotes?**
**R:** Adicione pacotes ao módulo apropriado:
- **Pacotes do usuário**: `/etc/nixos/modules/packages/home/`
- **Pacotes do sistema**: `/etc/nixos/modules/packages/system/`
- **Módulos customizados**: Criar novos arquivos em `/etc/nixos/modules/`

### **P: Posso usar isto com diferentes ambientes desktop?**
**R:** Atualmente otimizado para Hyprland, mas você pode:
- Manter Hyprland e adicionar outros DEs
- Substituir Hyprland editando `/etc/nixos/modules/system/desktop.nix`
- Desabilitar pacotes desktop e instalar seu DE preferido

## 🔧 Compatibilidade de Hardware

### **P: Quais GPUs são suportadas?**
**R:** Suporte completo para:
- **AMD**: Todas GPUs AMD modernas com drivers AMDGPU
- **NVIDIA**: Série GTX 900 e mais recentes (drivers proprietários)
- **Intel**: Todos gráficos integrados Intel

O instalador detecta automaticamente sua GPU e configura os drivers apropriados.

### **P: Isto funciona em laptops?**
**R:** Sim! Recursos específicos para laptop:
- Otimização de bateria
- Suporte Bluetooth
- Gerenciamento WiFi
- Gerenciamento de energia
- Controle de brilho
- Habilitar com: `laptop.enable = true;`

### **P: Posso usar isto com múltiplos monitores?**
**R:** Absolutamente! Hyprland tem excelente suporte multi-monitor:
- Detecção automática de monitores
- Workspaces por monitor
- Taxas de atualização e resoluções mistas
- Configuração fácil através da config do Hyprland

### **P: E quanto a hardware mais antigo?**
**R:** A configuração funciona na maioria dos hardwares, mas:
- **GPUs muito antigas**: Podem precisar de configuração manual de driver
- **RAM limitada**: Desabilitar recursos pesados (gaming, pacotes de desenvolvimento)
- **Armazenamento lento**: Instalação demorará mais mas funciona bem
- **Sistemas 32-bit**: Não suportados (requisito do NixOS)

### **P: Posso usar dual boot com Windows?**
**R:** Sim, mas requer cuidado:
- Instale Windows primeiro, depois NixOS
- O instalador preserva entradas de boot existentes
- GRUB é configurado para detectar outros sistemas operacionais
- Discos adicionais podem ser compartilhados entre sistemas

## 🎛️ Sistema de Feature Flags

### **P: O que são feature flags?**
**R:** Feature flags são chaves booleanas que habilitam/desabilitam partes da configuração:
```nix
features = {
  gaming.enable = true;      # Habilitar pacotes e otimizações de gaming
  laptop.enable = false;     # Desabilitar recursos específicos de laptop
  bluetooth.enable = false;  # Desabilitar suporte Bluetooth
};
```

### **P: Posso criar feature flags personalizadas?**
**R:** Sim! Adicione a `variables.nix`:
```nix
features = {
  meuRecurso.enable = true;
};
```
Então referencie em seus módulos:
```nix
{ config, lib, ... }:
let
  vars = import ../config/variables.nix;
in {
  config = lib.mkIf vars.features.meuRecurso.enable {
    # Sua configuração aqui
  };
}
```

### **P: Como vejo todas as feature flags disponíveis?**
**R:** Verifique `/etc/nixos/config/variables.nix` para todas opções disponíveis, ou veja a documentação [Configuration Reference](CONFIGURATION_REFERENCE.md).

### **P: Posso ter diferentes perfis (trabalho/gaming/etc)?**
**R:** Atualmente, você pode:
- Salvar diferentes presets com o instalador
- Alternar feature flags manualmente conforme necessário
- Versões futuras terão alternância de perfil integrada

## 📁 Integração de Dotfiles

### **P: Como funciona a integração de dotfiles?**
**R:** O instalador pode:
- Detectar diretórios de dotfiles existentes
- Aplicar dotfiles usando GNU Stow
- Suportar tanto estrutura de pacotes quanto estrutura direta
- Lidar com conflitos graciosamente

### **P: Qual estrutura de dotfiles é suportada?**
**R:** Duas estruturas:
1. **Estrutura de Pacotes** (subdiretórios):
   ```
   ~/.dotfiles/
   ├── zsh/
   │   └── .zshrc
   ├── git/
   │   └── .gitconfig
   └── vim/
       └── .vimrc
   ```

2. **Estrutura Direta** (arquivos diretamente):
   ```
   ~/.dotfiles/
   ├── .zshrc
   ├── .gitconfig
   └── .vimrc
   ```

### **P: Posso usar meus dotfiles existentes?**
**R:** Sim! O instalador:
- Detecta dotfiles existentes
- Oferece relocalizá-los se necessário
- Os aplica automaticamente após configuração do sistema
- Lida com conflitos perguntando sua preferência

### **P: E se dotfiles conflitarem com config do sistema?**
**R:** O sistema lida com conflitos por:
- Configuração do sistema tem precedência para funcionalidade core
- Dotfiles fornecem customizações específicas do usuário
- Resolução manual necessária para conflitos maiores
- Opções de backup disponíveis para segurança

## 🎮 Performance e Gaming

### **P: Quão boa é a performance de gaming?**
**R:** Excelente performance de gaming com:
- **Jogos nativos Linux**: Performance quase nativa
- **Jogos Proton/Wine**: Tipicamente 90-95% da performance Windows
- **Otimizações**: Governor CPU, agendadores I/O, parâmetros de kernel
- **Ferramentas**: Steam, Lutris, GameMode, MangoHud incluídos

### **P: Como habilito otimizações de gaming?**
**R:** Múltiplas maneiras:
1. **Durante instalação**: Habilitar pacotes de gaming
2. **Scripts sob demanda**: 
   ```bash
   gaming-mode-on   # Habilitar otimizações
   gaming-mode-off  # Restaurar padrões
   ```
3. **Feature flag**: Definir `gaming.enable = true;` em `variables.nix`

### **P: Quais jogos funcionam bem?**
**R:** Grande compatibilidade com:
- **Jogos Steam**: Excelente compatibilidade Proton
- **Jogos nativos Linux**: Performance perfeita
- **Jogos indie**: Geralmente funcionam perfeitamente
- **Jogos AAA**: Maioria funciona bem com Proton
- **Jogos anti-cheat**: Suporte limitado (melhorando)

### **P: Posso usar isto para streaming/criação de conteúdo?**
**R:** Sim! Inclui:
- **OBS Studio**: Para streaming e gravação
- **Ferramentas de áudio**: Configuração de áudio profissional com PipeWire
- **Performance**: Otimizado para taxas de quadro estáveis
- **Multi-monitor**: Excelente suporte para configurações de streaming

## 🔧 Solução de Problemas

### **P: O script instalador não inicia**
**R:** Soluções comuns:
```bash
# Tornar executável
chmod +x install.sh

# Verificar se está no NixOS
cat /etc/NIXOS

# Instalar dependências
nix-shell -p git curl coreutils
```

### **P: Rebuild falha com erros de sintaxe**
**R:** Verifique sua configuração:
```bash
# Validar sintaxe
nix-instantiate --parse /etc/nixos/config/variables.nix

# Problemas comuns: ponto-e-vírgulas ausentes, chaves não correspondentes
sudo nano /etc/nixos/config/variables.nix
```

### **P: Sistema não inicializa após instalação**
**R:** Passos de recuperação:
1. **Inicializar do ISO NixOS**
2. **Rollback**: `nixos-rebuild --rollback`
3. **Verificar logs**: `journalctl -xb`
4. **Veja [TROUBLESHOOTING.md](TROUBLESHOOTING.md) para recuperação detalhada**

### **P: Drivers de GPU não funcionam**
**R:** Soluções:
1. **Verificar detecção**: Verifique `/etc/nixos/config/variables.nix`
2. **Substituição manual**: Edite tipo de GPU em variables.nix
3. **Verificar carregamento**: `lsmod | grep -E "nvidia|amdgpu"`
4. **Rebuild**: `rebuild` após mudanças

## 🚀 Uso Avançado

### **P: Posso usar isto em uma VM?**
**R:** Sim, mas com considerações:
- Desabilitar recursos específicos de hardware (aceleração GPU)
- Reduzir pacotes intensivos em recursos
- Habilitar otimizações específicas de virtualização
- Pode precisar de configuração manual de hardware

### **P: Como contribuo para esta configuração?**
**R:** Contribuições bem-vindas:
1. **Fork do repositório** no GitHub
2. **Siga padrões de codificação** em [CODING_STANDARDS.md](CODING_STANDARDS.md)
3. **Teste minuciosamente** no seu hardware
4. **Submeta pull request** com descrição clara
5. **Inclua português e inglês** para mudanças voltadas ao usuário

### **P: Posso usar isto para servidores?**
**R:** Possível mas não otimal:
- Esta config é focada em desktop
- Desabilitar pacotes GUI: `desktop.enable = false;`
- Criar feature flags específicas para servidor
- Considere usar config mínima de servidor NixOS em vez disso

### **P: Como atualizo para versões mais novas?**
**R:** Métodos de atualização:
1. **Re-executar instalador**: `./install.sh` com versão mais nova
2. **Atualização manual**: `cd /etc/nixos && nix flake update`
3. **Monitorar releases**: Verificar GitHub para atualizações
4. **Backup primeiro**: Sempre fazer backup antes de atualizações maiores

## 🔄 Comparação com Outras Configurações

### **P: Como isto se compara com outras configs NixOS?**
**R:** Vantagens:
- **Universal**: Funciona em qualquer hardware via feature flags
- **Instalador interativo**: Não precisa de configuração manual  
- **Foco em gaming**: Otimizações e ferramentas integradas
- **Multilíngue**: Suporte português e inglês
- **Abrangente**: Tudo incluído out-of-the-box

### **P: Devo usar isto ou criar minha própria config?**
**R:** Use isto se você quer:
- ✅ Configuração rápida com padrões inteligentes
- ✅ Foco em gaming e desenvolvimento
- ✅ Atualizações regulares e suporte da comunidade
- ✅ Configuração comprovada com bom suporte de hardware

Crie sua própria se você:
- ❌ Precisa de configuração muito específica/mínima
- ❌ Quer aprender NixOS profundamente
- ❌ Tem requisitos de hardware incomuns
- ❌ Prefere ambiente desktop diferente

### **P: Posso migrar de outras distribuições Linux?**
**R:** Sim, mas considere:
- **Gerenciamento de pacotes diferente**: Nix vs pacotes tradicionais
- **Abordagem de configuração**: Declarativa vs imperativa
- **Curva de aprendizado**: Conceitos NixOS levam tempo para dominar  
- **Benefícios**: Reproduzibilidade, rollbacks, atualizações atômicas

### **P: Como isto se compara com configurações de gaming Arch/Manjaro?**
**R:** Comparação:

| Recurso | Esta Config NixOS | Arch/Manjaro |
|---------|------------------|--------------|
| **Tempo de Configuração** | 30-60 min automatizado | Horas de trabalho manual |
| **Performance Gaming** | Excelente, otimizada | Excelente com ajuste manual |
| **Estabilidade** | Muito estável, rollbacks | Boa, recuperação manual |
| **Customização** | Feature flags, módulos | Controle manual completo |
| **Atualizações** | Atômicas, seguras | Rolling, pode quebrar |
| **Reproduzibilidade** | Perfeita | Documentação manual necessária |

## 📞 Obtendo Mais Ajuda

### **P: Onde posso obter ajuda se minha pergunta não estiver aqui?**
**R:** Várias opções:
- **Verifique [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** para problemas técnicos
- **GitHub Issues**: Relatórios de bugs e solicitações de recursos
- **NixOS Discourse**: Discussões da comunidade
- **Matrix/Discord**: Suporte de chat em tempo real
- **Documentação**: Leia os guias completos em `/docs`

### **P: Como reporto bugs ou solicito recursos?**
**R:** Por favor:
1. **Verifique issues existentes** no GitHub primeiro
2. **Forneça informações do sistema**: Versão NixOS, especificações de hardware
3. **Inclua mensagens de erro**: Logs completos e saída de erro
4. **Descreva comportamento esperado**: O que deveria acontecer vs o que acontece
5. **Inclua configuração**: Partes relevantes de `variables.nix`

### **P: Posso ajudar a melhorar esta documentação?**
**R:** Absolutamente! Bem-vindos:
- **Correções e esclarecimentos**
- **Perguntas e respostas adicionais**
- **Melhorias de tradução**
- **Novas seções para problemas comuns**
- **Melhores exemplos e explicações**

Submeta melhorias via pull requests ou issues no GitHub.

---

**Não encontrou sua pergunta?** Por favor [crie uma issue](https://github.com/JakeMartinezz/hyprland-nix/issues) no GitHub, e nós a adicionaremos a este FAQ!