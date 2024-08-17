{ stdenv, fetchurl, zstd }:

stdenv.mkDerivation {
  name = "aarch64-image";
  src = fetchurl {
    # unfortunally there is no easy way right now to reproduce the same evaluation
    # as hydra, since `pkgs.path` is embedded in the binary
    url = "https://hydra.nixos.org/build/269682674/download/1/nixos-sd-image-24.05.3914.c3d4ac725177-aarch64-linux.img.zst";
    sha256 = "0c7kqgp77433zq1710lpjwpmr06wvgx19767p9hlafa849lmq76q";
  };
  preferLocalBuild = true;
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  nativeBuildInputs = [
    zstd
  ];

  installPhase = ''
    zstdcat $src > $out
  '';
}