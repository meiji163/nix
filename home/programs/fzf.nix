{ config, pkgs, lib, ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--bind 'alt-c:clear-query'"
      "--bind 'alt-u:first,alt-d:last'"
      "--bind 'alt-r:refresh-preview'"
      "--bind 'ctrl-w:preview-half-page-up,ctrl-s:preview-half-page-down'"
    ];
  };
}
