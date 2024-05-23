{
  description =
    "Collection of nix-compatible color schemes, and a home-manager module to make theming easier.";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    # Upstream source of .yaml schemes
    schemes.url = "github:tinted-theming/schemes";
    schemes.flake = false;
  };

  outputs = { self, nixpkgs-lib, schemes }:
    import ./. {
      nixpkgs-lib = nixpkgs-lib.lib;
      schemes = schemes.outPath;
    };
}
