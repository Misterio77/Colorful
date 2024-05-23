# Nix Colors

# About
This repo is designed to help with Nix(OS) theming.

At the core, we expose a nix attribute set with 220+ base16 schemes, as well as
a [home-manager](https://github.com/nix-community/home-manager) module for
globally setting your preferred one.

These schemes are not vendored in: they are directly fetch (and flake locked!)
from [tinted-schemes](https://github.com/tinted-theming/schemes), then
converted using our (pure nix) `schemeFromYAML` function, which is also exposed
for your convenience. This means you can easily make your own schemes, in
either nix-colors (`.nix`) or base16 (`.yaml`) format, freely converting
between the two.

The core portion of nix-colors is very unopinionated and should work with all
possible workflows very easily, without any boilerplate code.

We also have some optional contrib functions for opinionated, common use cases
(generating scheme from image, generating wallpaper, vim scheme, gtk theme).

## Base16?
[Base16](https://github.com/base16-project/base16) (now is [Tinted Theming](https://github.com/tinted-theming/home)) is a standard for defining
palettes (schemes), and how each app should be themed (templates).

nix-colors focuses on delivering and helping you use the schemes, all in a
Nix-friendly way.

## `system` in color schemes?
This is the style of color schemes. There are two kinds of style supported currently: Base16 and Base24. See [Tinted Theming's readme](https://github.com/tinted-theming/home?tab=readme-ov-file#style) for more information.

# Setup

The usual setup looks like this:
- Either add the repo to your flake inputs, or add the channel on a legacy
  setup.
- Import the home-manager module `nix-colors.homeManagerModules.default`
- Set the option `colorScheme` to your preferred color scheme, such as
  `nix-colors.colorSchemes.base16.dracula` (or create/convert your own)
- Use `config.colorScheme.palette.base0X` to refer to any of the 16 colors from
  anywhere!

## Importing

### Flake
First add `nix-colors` to your flake inputs:
```nix
{
  inputs = {
    # ...
    nix-colors.url = "github:misterio77/nix-colors";
  };
}
```

Then, you need some way to pass this onwards to your `home-manager`
configuration.

If you're using standalone home-manager, use `extraSpecialArgs` for this:
```nix
homeConfigurations = {
  "foo@bar" = home-manager.lib.homeManagerConfiguration {
    # ...
    extraSpecialArgs = { inherit nix-colors; };
  };
};
```

Or, if using it as a NixOS module, use `specialArgs` on your flake (and
`extraSpecialArgs` wherever you import your home nix file):
```nix
nixosConfigurations = {
  bar = nixpkgs.lib.nixosSystem {
    # ...
    specialArgs = { inherit nix-colors; };
  };
};
```


### Legacy (non-flake)
If you're not using flakes, the most convenient method is adding nix-colors to
your channels:
```
nix-channel --add https://github.com/misterio77/nix-colors/archive/main.tar.gz nix-colors
nix-channel --update
```

Then, instead of adding `nix-colors` as a argument in your config file(s), use
a let binding. For example:

```nix
{ pkgs, config, ... }: # Don't put 'nix-colors' here
let
  nix-colors = import <nix-colors> { };
in {
  import = [
    nix-colors.homeManagerModules.default
  ];

  colorScheme = nix-colors.colorSchemes.base16.paraiso;

  # ...
}
```

## Using

With that done, move on to your home manager configuration.

You should import the `nix-colors.homeManagerModules.default`, and set the option
`colorScheme` to your preferred scheme, such as
`nix-colors.colorSchemes.base16.dracula`

Here's a quick example on how to use it with, say, a terminal emulator (kitty)
and a browser (qutebrowser):
```nix
{ pkgs, config, nix-colors, ... }: {
  imports = [
    nix-colors.homeManagerModules.default
  ];

  colorScheme = nix-colors.colorSchemes.base16.dracula;

  programs = {
    kitty = {
      enable = true;
      settings = {
        foreground = "#${config.colorScheme.palette.base05}";
        background = "#${config.colorScheme.palette.base00}";
        # ...
      };
    };
    qutebrowser = {
      enable = true;
      colors = {
        # Becomes either 'dark' or 'light', based on your colors!
        webppage.preferred_color_scheme = "${config.colorScheme.variant}";
        tabs.bar.bg = "#${config.colorScheme.palette.base00}";
        keyhint.fg = "#${config.colorScheme.palette.base05}";
        # ...
      };
    };
  };
}
```

If you change `colorScheme` for anything else (say,
`nix-colors.colorSchemes.base16.nord`), both qutebrowser and kitty will match the new
scheme! Awesome!

You can, of course, specify (or generate somehow) your nix-colors scheme directly:
```nix
{
  colorScheme = {
    system = "base16";
    slug = "pasque";
    name = "Pasque";
    author = "Gabriel Fontes (https://github.com/Misterio77)";
    palette = {
      base00 = "#271C3A";
      base01 = "#100323";
      base02 = "#3E2D5C";
      base03 = "#5D5766";
      base04 = "#BEBCBF";
      base05 = "#DEDCDF";
      base06 = "#EDEAEF";
      base07 = "#BBAADD";
      base08 = "#A92258";
      base09 = "#918889";
      base0A = "#804ead";
      base0B = "#C6914B";
      base0C = "#7263AA";
      base0D = "#8E7DC6";
      base0E = "#953B9D";
      base0F = "#59325C";
    };
  };
}
```

This is it for basic usage! You're ready to `nix`ify your `colors`. Read on if
you're interested in converting schemes between our format and base16's, or
want to check out our opinionated contrib functions.

# Lib functions

## Core

Our core functions do not require nixpkgs. Nix all the way down (at least until
you get to nix-the-package-manager code) baby!

All of these are exposed at `nix-colors.lib`.

### `schemeFromYAML`

This function is used internally to convert base16's schemes to nix-colors
format, but is exposed so you can absolutely do the same.

Just grab (or create yours) a `.yaml` file, read it into a string (with
`readFile`, for example) and you're golden:
```nix
{ nix-colors, ... }:
{
  colorScheme = nix-colors.lib.schemeFromYAML "cool-scheme" (builtins.readFile ./cool-scheme.yaml);
}
```

This path can come from wherever nix can read, even another repo! That's what
we do to expose base16's schemes.

### More soon(TM)

We plan on helping you turn existing base16 templates into nifty nix functions
real soon, as well as converting colors between hex and decimal. Stay tuned!

## Contributed functions

We also have a few opinionated functions for some common scheme usecases: such
as generating schemes from an image, generating an image from a scheme... You get
the idea.

These nifty pals are listed (and documented) at
[`lib/contrib/default.nix`](lib/contrib/default.nix). They are exposed at
`nix-colors.lib.contrib`.

Do note these require `nixpkgs`, however. You should pass your `pkgs` instance
to `nix-colors.lib.contrib` to use them. For example:
```nix
{ pkgs, nix-colors, ... }:

let
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  colorScheme = nix-colors-lib.colorSchemeFromPicture {
    path = ./wallpapers/example.png;
    variant = "light";
  };
}
```

# Upstreaming new schemes

Please share nice schemes you have created to upstream!

It's pretty easy to do. Just open up a PR on
[tinted-schemes](https://github.com/tinted-theming/schemes), and once
it's in it will be available here.

If it takes a while to be merged, you can temporarily put it together with your
config and use [`schemeFromYAML`](#schemeFromYAML) to load it.

Alternatively, you can tell nix-colors to follow your base16-schemes fork.

In your flake inputs, add `schemes` and override
  `nix-colors.inputs.schemes.follows`:
```nix
{
  description = "Your cool config flake";
  inputs = {
    schemes = "github:you/schemes"; # Your base16-schemes fork

    nix-colors.url = "github:misterio77/nix-colors";
    nix-colors.inputs.schemes.follows = "schemes"; # Be sure to add this
    # ...
  };
  # ...
}
```

# Thanks

Special thanks to rycee for most of this repo's inspiration, plus for the amazing home-manager.

Huge thanks for everyone involved with base16.

Gigantic thanks to arcnmx, for his pure-nix `fromYAML` function.

Extra special thanks for my folks at the NixOS Brasil Telegram group, for willing to try this out!
