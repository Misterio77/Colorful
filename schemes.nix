{ lib, schemes, ... }:
let
  inherit (builtins)
    readFile readDir attrNames listToAttrs stringLength substring baseNameOf
    filter;
  inherit (lib) schemeFromYAML;

  # Borrowed from nixpkgs
  removeSuffix = suffix: str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str then
      substring 0 (sLen - sufLen) str
    else
      str;
  hasSuffix = suffix: content:
    let
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix
    && substring (lenContent - lenSuffix) lenContent content == suffix;

  stripYamlExtension = filename:
    removeSuffix ".yml" (removeSuffix ".yaml" filename);
  isYamlFile = filename:
    (hasSuffix ".yml" filename) || (hasSuffix ".yaml" filename);

  getColorSchemeFiles = source: system:
    filter isYamlFile (attrNames (readDir "${source}/${system}"));

  getColorSchemes = colorSchemeFiles: system:
    listToAttrs (map
      (filename: rec {
        # Scheme slug
        name = stripYamlExtension (baseNameOf filename);
        # Scheme contents
        value = schemeFromYAML name (readFile "${schemes}/${system}/${filename}");
      })
      colorSchemeFiles);

  colorSchemeFiles = {
    base16 = getColorSchemeFiles schemes "base16";
    base24 = getColorSchemeFiles schemes "base24";
  };

  colorSchemes = {
    base16 = getColorSchemes colorSchemeFiles.base16 "base16";
    base24 = getColorSchemes colorSchemeFiles.base24 "base24";
  };
in
colorSchemes
