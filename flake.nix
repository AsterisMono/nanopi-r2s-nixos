{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    ehfive = {
      url = "github:EHfive/flakes";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
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
    buildImage = pkgs.callPackage ./pkgs/build-image {};
    aarch64Image = pkgs.callPackage ./pkgs/aarch64-image.nix {};
    rockchip = uboot: pkgs.callPackage ./images/rockchip.nix {
      inherit uboot aarch64Image buildImage;
    };
  in {
    images = {
      nixos-installer-r2s = rockchip inputs.ehfive.packages.aarch64-linux.ubootNanopiR2s;
    };
    nixosConfigurations = {
      nanopi-r2s = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./nixosModules
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                inherit (inputs.ehfive.packages.${pkgs.system})
                  rtl8152-led-ctrl;
              })
            ];
          })
        ];
      };
    };
  };
}