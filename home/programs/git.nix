{ pkgs, lib, ... }:
{
  enable = true;
  userName = "meiji163";
  userEmail = "meiji163@github.com";
  
  # Add any additional git configuration here
  extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = false;
  };
}
