{ lib, config, ... }:

with lib;
let
  cfg = config.colorScheme;
  hexColorType = mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = x: isString x && !(hasPrefix "#" x);
  };
in
{
  imports = [
    (mkAliasOptionModule [ "colorscheme" ] [ "colorScheme" ])
    (mkRenamedOptionModule [ "colorScheme" "kind" ] [ "colorScheme" "variant" ])
    (mkRenamedOptionModule [ "colorScheme" "colors" ] [ "colorScheme" "palette" ])
  ];

  options.colorScheme = {
    system = mkOption {
      type = types.str;
      default = "base16";
      example = "base16";
      description = ''
        Color scheme system
      '';
    };
    slug = mkOption {
      type = types.str;
      example = "awesome-scheme";
      description = ''
        Color scheme slug (sanitized name)
      '';
    };
    name = mkOption {
      type = types.str;
      default = "";
      example = "Awesome Scheme";
      description = ''
        Color scheme (pretty) name
      '';
    };
    description = mkOption {
      type = types.str;
      default = "";
      example = "A very nice theme";
      description = ''
        Color scheme description
      '';
    };
    author = mkOption {
      type = types.str;
      default = "";
      example = "Gabriel Fontes (https://m7.rs)";
      description = ''
        Color scheme author
      '';
    };
    variant = mkOption {
      type = types.enum [ "dark" "light" ];
      default =
        if builtins.substring 0 1 cfg.palette.base00 < "5" then
          "dark"
        else
          "light";
      description = ''
        Whether the scheme is dark or light
      '';
    };

    palette = mkOption {
      type = with types; attrsOf (
        coercedTo str (removePrefix "#") hexColorType
      );
      default = { };
      example = literalExpression ''
        {
          base00 = "002635";
          base01 = "00384d";
          base02 = "517F8D";
          base03 = "6C8B91";
          base04 = "869696";
          base05 = "a1a19a";
          base06 = "e6e6dc";
          base07 = "fafaf8";
          base08 = "ff5a67";
          base09 = "f08e48";
          base0A = "ffcc1b";
          base0B = "7fc06e";
          base0C = "14747e";
          base0D = "5dd7b9";
          base0E = "9a70a4";
          base0F = "c43060";
        }
      '';
      description = ''
        Atribute set of hex colors.

        These are usually base00-base0F, but you may use any name you want.
        For example, these can have meaningful names (bg, fg), or be base24.

        The colorschemes provided by nix-colors follow the base16 standard.
        Some might leverage base24 and have 24 colors, but these can be safely
        used as if they were base16.

        You may include a leading #, but it will be stripped when accessed from
        config.colorscheme.palette.
      '';
    };
  };
}
