{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    configure = {
      customRC = ''
        " Basic settings
        set number
        set relativenumber
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
        set mouse=a
        set clipboard=unnamedplus
        
        " Search settings
        set ignorecase
        set smartcase
        set incsearch
        set hlsearch
        
        " UI settings
        set termguicolors
        set signcolumn=yes
        set cursorline
        
        " Colorscheme
        colorscheme slate
      '';
      
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          vim-nix
          vim-commentary
          vim-surround
          vim-fugitive
        ];
      };
    };
  };
}
