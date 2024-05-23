{ nixpkgs-lib }: {
  /* Convert a slug name and base16-compatible YAML string into a nix-colors-compatible scheme

     Example:
     schemeFromYAML "pasque" (builtins.readFile ./pasque.yaml) =>
     {
       system = "base16";
       author = "Gabriel Fontes (https://github.com/Misterio77)";
       name = "Pasque";
       slug = "pasque";
       palette = {
         base00 = "271C3A";
         base01 = "100323";
         base02 = "3E2D5C";
         base03 = "5D5766";
         base04 = "BEBCBF";
         base05 = "DEDCDF";
         base06 = "EDEAEF";
         base07 = "BBAADD";
         base08 = "A92258";
         base09 = "918889";
         base0A = "804ead";
         base0B = "C6914B";
         base0C = "7263AA";
         base0D = "8E7DC6";
         base0E = "953B9D";
         base0F = "59325C";
       };
     }
  */
  schemeFromYAML = import ./schemeFromYAML.nix;

  schemeToYAML = import ./schemeToYAML.nix { inherit nixpkgs-lib; };

  conversions = import ./conversions.nix { inherit nixpkgs-lib; };
}
