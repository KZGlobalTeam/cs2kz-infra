{ pkgs, system, sshKeys, ... }:

{
  environment = {
    systemPackages = with pkgs; [ coreutils vim ];
    defaultPackages = with pkgs; [ tmux curl git btop fd fzf neovim jq ripgrep ];
    variables.EDITOR = "nvim";
  };
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = system;
  programs.zsh.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "cs2kz@dawn.sh";
  };
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
  system.stateVersion = "24.05";
  time.timeZone = "Europe/Berlin";
  users = {
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = sshKeys;
  };
}
