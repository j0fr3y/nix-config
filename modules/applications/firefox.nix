{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    
    profiles.default = {
      settings = {
        # Enable Wayland backend
        "MOZ_ENABLE_WAYLAND" = 1;
        
        # Privacy settings
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        
        # UI improvements
        "browser.tabs.loadBookmarksInTabs" = true;
        "browser.urlbar.suggest.searches" = true;
        
        # Performance
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;
      };
      
      search = {
        default = "DuckDuckGo";
        force = true;
      };
    };
  };
}
