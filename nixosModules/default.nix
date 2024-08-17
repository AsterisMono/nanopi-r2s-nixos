{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  nixpkgs.crossSystem = {
    config = "aarch64-linux-gnu";
  };

  networking.hostName = "nanopi-r2s";
  networking.useDHCP = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
