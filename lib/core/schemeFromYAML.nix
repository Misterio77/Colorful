let
  inherit (builtins)
    elemAt filter listToAttrs substring replaceStrings stringLength genList;

  # All of these are borrowed from nixpkgs
  mapListToAttrs = f: l: listToAttrs (map f l);
  escapeRegex = escape (stringToCharacters "\\[{()^$?*+|.");
  addContextFrom = a: b: substring 0 0 a + b;
  escape = list: replaceStrings list (map (c: "\\${c}") list);
  range = first: last:
    if first > last then [ ] else genList (n: first + n) (last - first + 1);
  stringToCharacters = s:
    map (p: substring p 1 s) (range 0 (stringLength s - 1));
  splitString = _sep: _s:
    let
      sep = builtins.unsafeDiscardStringContext _sep;
      s = builtins.unsafeDiscardStringContext _s;
      splits = filter builtins.isString (builtins.split (escapeRegex sep) s);
    in
    map (v: addContextFrom _sep (addContextFrom _s v)) splits;
  nameValuePair = name: value: { inherit name value; };

  # From https://github.com/arcnmx/nixexprs
  fromYAML = yaml:
    let
      stripLine = line: elemAt (builtins.match "(^[^#]*)($|#.*$)" line) 0;
      usefulLine = line: builtins.match "[ \\t]*" line == null;
      parseString = token:
        let match = builtins.match ''([^"]+|"([^"]*)" *)'' token;
        in if match == null then
          throw ''YAML string parse failed: "${token}"''
        else if elemAt match 1 != null then
          elemAt match 1
        else
          elemAt match 0;
      attrLine = line:
        let match = builtins.match "^ *([^ :]+): *(.*)" line;
        in if match == null then
          throw ''YAML parse failed: "${line}"''
        else
          nameValuePair (elemAt match 0) (parseString (elemAt match 1));
      lines = splitString "\n" yaml;
      lines' = map stripLine lines;
      lines'' = filter usefulLine lines';
    in
    mapListToAttrs attrLine lines'';

  convertScheme = slug: set: system: {
    inherit system;
    name = set.scheme;
    inherit (set) author;
    inherit slug;
    palette =
      if system == "base16" then {
        inherit (set)
          base00 base01 base02 base03 base04 base05 base06 base07 base08 base09
          base0A base0B base0C base0D base0E base0F;
      }
      else if system == "base24" then {
        inherit (set)
          base00 base01 base02 base03 base04 base05 base06 base07 base08 base09
          base0A base0B base0C base0D base0E base0F
          base10 base11 base12 base13 base14 base15 base16 base17;
      }
      else
        throw "Unsupported color scheme system: ${system}";
  };

  schemeFromYAML = slug: content: convertScheme slug (fromYAML content) (fromYAML content).system;
in
schemeFromYAML
