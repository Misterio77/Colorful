{ nixpkgs-lib }:
let
  inherit (builtins) concatStringsSep map;
  inherit (nixpkgs-lib) optional;

  # From nixpkgs, but with newline
  concatMapStrings = f: list: concatStringsSep "\n" (map f list);

  colorNames = system:
    map (n: "base0${n}") [
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
      "A"
      "B"
      "C"
      "D"
      "E"
      "F"
    ] ++ optional system == "base24" map (n: "base1${n}") [
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
    ];

  schemeToYAML = scheme:
    ''
      system: "${scheme.system}"
      scheme: "${scheme.name}"
      author: "${scheme.author}"
    '' + concatMapStrings # Add a line for each base0X color
      (color: ''${color}: "${scheme.palette.${color}}"'')
      colorNames scheme.system;
in
schemeToYAML
