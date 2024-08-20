{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    ehfive = {
      url = "github:EHfive/flakes";
      # Do not use follows - use uboot in binary cache
    };
  };

  nixConfig = {
    # substituer
    substituters = ["https://eh5.cachix.org"];
    trusted-public-keys = ["eh5.cachix.org-1:pNWZ2OMjQ8RYKTbMsiU/AjztyyC8SwvxKOf6teMScKQ="];
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let
    pkgs = import nixpkgs {
      config.allowUnfree = true;
      system = "x86_64-linux";
    };
    nixosModules = [
      ./nixosConfiguration
      ({ pkgs, ... }: {
        nixpkgs.overlays = [
          (final: prev: {
            inherit (inputs.ehfive.packages.${pkgs.system})
              rtl8152-led-ctrl;
          })
        ];
      })
    ];
  in {
    nixosConfigurations = {
      nanopi-r2s = nixpkgs.lib.nixosSystem {
        modules = nixosModules;
        system = "aarch64-linux";
      };
    };
    packages.x86_64-linux = {
      aarch64Image = pkgs.callPackage ./pkgs/aarch64-image.nix {};
      nixos-installer-r2s = self.lib.rockchip inputs.ehfive.packages.aarch64-linux.ubootNanopiR2s;
    };
    lib = {
      buildImage = pkgs.callPackage ./pkgs/build-image {};
      rockchip = uboot: pkgs.callPackage ./images/rockchip.nix {
        inherit uboot;
        inherit (self.packages.x86_64-linux) aarch64Image;
        inherit (self.lib) buildImage;
      };
    };
  };
}