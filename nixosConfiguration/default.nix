{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "nanopi-r2s";
  networking.useDHCP = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    extraGroups = [ "wheel" ];
    initialHashedPassword = "$y$j9T$wc2lKY86ERXjQErBduX5H.$yC8FudbkoJ0bleapUXg0cWhHcmXuLE6TPhDNi7ihEi/"; # nixos
  };

  system.stateVersion = "24.05";
}
