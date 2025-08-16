{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Development tools and editors
    claude-code
    vscode
    
    # Programming languages and runtimes
    bun
    yarn
    
    # CLI tools for development  
    fd
    ripgrep
    jq
    
    
    # Note: python3 moved to system core packages (more fundamental)
  ];
}