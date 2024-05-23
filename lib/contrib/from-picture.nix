{ nixpkgs-lib, pkgs }:
{
  path,
  system ? "base16",
  variant ? kind,
  kind ? "light" # Older alias
}:
import (pkgs.stdenv.mkDerivation {
  inherit (nixpkgs-lib) optional;
  name = "generated-colorscheme";
  buildInputs = with pkgs; [ flavours ];
  unpackPhase = "true";
  buildPhase = ''
    template=$(cat <<-END
    {
      system = "${system}";
      slug = "$(basename ${path} | cut -d '.' -f1)-${variant}";
      name = "Generated";
      author = "nix-colors";
      palette = {
        base00 = "{{base00-hex}}";
        base01 = "{{base01-hex}}";
        base02 = "{{base02-hex}}";
        base03 = "{{base03-hex}}";
        base04 = "{{base04-hex}}";
        base05 = "{{base05-hex}}";
        base06 = "{{base06-hex}}";
        base07 = "{{base07-hex}}";
        base08 = "{{base08-hex}}";
        base09 = "{{base09-hex}}";
        base0A = "{{base0A-hex}}";
        base0B = "{{base0B-hex}}";
        base0C = "{{base0C-hex}}";
        base0D = "{{base0D-hex}}";
        base0E = "{{base0E-hex}}";
        base0F = "{{base0F-hex}}";
  '' ++ optional system == "base24" ''
        base10 = "{{base10-hex}}";
        base11 = "{{base11-hex}}";
        base12 = "{{base12-hex}}";
        base13 = "{{base13-hex}}";
        base14 = "{{base14-hex}}";
        base15 = "{{base15-hex}}";
        base16 = "{{base16-hex}}";
        base17 = "{{base17-hex}}";
  '' ++ ''
      };
    }
    END
    )

    flavours generate "${variant}" "${path}" --stdout | \
    flavours build <( tee ) <( echo "$template" ) > default.nix
  '';
  installPhase = "mkdir -p $out && cp default.nix $out";
})
