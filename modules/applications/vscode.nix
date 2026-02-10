{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    extensions = with pkgs.vscode-extensions; [
      # Nix support
      bbenoist.nix
      
      # Git
      eamodio.gitlens
      
      # Languages
      ms-python.python
      ms-vscode.cpptools
      
      # Themes
      pkief.material-icon-theme
    ];
    
    userSettings = {
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.formatOnSave" = true;
      "workbench.colorTheme" = "Default Dark+";
      "workbench.iconTheme" = "material-icon-theme";
      "terminal.integrated.fontFamily" = "'JetBrains Mono'";
      "files.autoSave" = "onFocusChange";
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
    };
  };
}
