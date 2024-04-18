{pkgs}: {scheme}: let
  # make shorthand for a rendersvg command, has to do with icons / something else?
  rendersvg = pkgs.runCommand "rendersvg" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';
  # mkdir rendersvg if directory does not already exist ( -p flag )
  # ln -s symlinks find dir of resvg binary add to out / bin / rendersvg
  # must be staging to render svg with a colour palette?
in
  pkgs.stdenv.mkDerivation rec {
    name = "generated-gtk-theme-${scheme.slug}";
    src = pkgs.fetchFromGitHub {
      owner = "nana-4";
      repo = "materia-theme";
      rev = "76cac96ca7fe45dc9e5b9822b0fbb5f4cad47984";
      sha256 = "sha256-0eCAfm/MWXv6BbCl2vbVbvgv8DiUH09TAUhoKq7Ow0k=";
    };
    buildInputs = with pkgs; [
      sassc
      bc
      which
      rendersvg
      meson
      ninja
      nodePackages.sass
      gtk4.dev
      optipng
    ];
    phases = ["unpackPhase" "installPhase"];

    # X=${if X = null then X = $Y else X = X}
    #
    # HDR_BG=${HDR_BG-$MENU_BG}
    # HDR_FG=${HDR_FG-$MENU_FG}
    # MATERIA_VIEW=${MATERIA_VIEW-$TXT_BG}
    # MATERIA_SURFACE=${MATERIA_SURFACE-$BTN_BG}

    # GNOME_SHELL_PANEL_OPACITY=${GNOME_SHELL_PANEL_OPACITY-0.6}
    # MATERIA_PANEL_OPACITY=${MATERIA_PANEL_OPACITY-$GNOME_SHELL_PANEL_OPACITY}

    # MATERIA_STYLE_COMPACT=$(tr '[:upper:]' '[:lower:]' <<< "${MATERIA_STYLE_COMPACT-False}")

    # MATERIA_COLOR_VARIANT=$(tr '[:upper:]' '[:lower:]' <<< "${MATERIA_COLOR_VARIANT:-}")

    # SPACING=${SPACING-3}
    # ROUNDNESS=${ROUNDNESS-4}

    # ROUNDNESS_GTK2_HIDPI=$(( ROUNDNESS * 2 ))

    # MATERIA_PANEL_OPACITY=${MATERIA_PANEL_OPACITY-0.6}
    # MATERIA_SELECTION_OPACITY=${MATERIA_SELECTION_OPACITY-0.32}

    # INACTIVE_FG=$(mix "$FG" "$BG" 0.75)
    # INACTIVE_MATERIA_VIEW=$(mix "$MATERIA_VIEW" "$BG" 0.60)

    # TERMINAL_COLOR4=${TERMINAL_COLOR4:-1E88E5}
    # TERMINAL_COLOR5=${TERMINAL_COLOR5:-E040FB}
    # TERMINAL_COLOR9=${TERMINAL_COLOR9:-DD2C00}
    # TERMINAL_COLOR10=${TERMINAL_COLOR10:-00C853}
    # TERMINAL_COLOR11=${TERMINAL_COLOR11:-FF6D00}
    # TERMINAL_COLOR12=${TERMINAL_COLOR12:-66BB6A}

    installPhase = ''
      HOME=/build
      chmod 777 -R .
      patchShebangs .
      mkdir -p $out/share/themes
      mkdir bin
      sed -e 's/handle-horz-.*//' -e 's/handle-vert-.*//' -i ./src/gtk-2.0/assets.txt

      cat > /build/gtk-colors << EOF

        TERMINAL_COLOR0=${scheme.palette.base00}
        TERMINAL_COLOR1=${scheme.palette.base08}
        TERMINAL_COLOR2=${scheme.palette.base0B}
        TERMINAL_COLOR3=${scheme.palette.base0A}
        TERMINAL_COLOR4=${scheme.palette.base0D}
        TERMINAL_COLOR5=${scheme.palette.base0E}
        TERMINAL_COLOR6=${scheme.palette.base0C}
        TERMINAL_COLOR7=${scheme.palette.base05}
        TERMINAL_COLOR8=${scheme.palette.base03}
        TERMINAL_COLOR9=${scheme.palette.base08}
        TERMINAL_COLOR10=${scheme.palette.base0B}
        TERMINAL_COLOR11=${scheme.palette.base0A}
        TERMINAL_COLOR12=${scheme.palette.base0D}
        TERMINAL_COLOR13=${scheme.palette.base0E}
        TERMINAL_COLOR14=${scheme.palette.base0C}
        TERMINAL_COLOR15=${scheme.palette.base07}

        BTN_BG=${scheme.palette.base02}
        BTN_FG=${scheme.palette.base06}

        FG=${scheme.palette.base05}
        BG=${scheme.palette.base00}

        HDR_BTN_BG=${scheme.palette.base01}
        HDR_BTN_FG=${scheme.palette.base05}

        ACCENT_BG=${scheme.palette.base0B}
        ACCENT_FG=${scheme.palette.base00}

        HDR_FG=${scheme.palette.base05}
        HDR_BG=${scheme.palette.base00}

        MATERIA_SURFACE=${scheme.palette.base00}
        MATERIA_VIEW=${scheme.palette.base01}

        MENU_BG=${scheme.palette.base01}
        MENU_FG=${scheme.palette.base06}

        SEL_BG=${scheme.palette.base0D}
        SEL_FG=${scheme.palette.base0E}

        TXT_BG=${scheme.palette.base00}
        TXT_FG=${scheme.palette.base06}

        WM_BORDER_FOCUS=${scheme.palette.base05}
        WM_BORDER_UNFOCUS=${scheme.palette.base03}

        UNITY_DEFAULT_LAUNCHER_STYLE=False
        NAME=${scheme.slug}
        MATERIA_STYLE_COMPACT=True
      EOF

      echo "Changing colours:"
      ./change_color.sh -o ${scheme.slug} /build/gtk-colors -i False -t "$out/share/themes"
      chmod 555 -R .
    '';
  }
