{
  appimageTools,
  fetchurl,
  makeDesktopItem,
  lib,
  ffmpeg,
  chromium,
  swiftshader,
  vulkan-loader,
  xorg,
  libGL,
}:
let
  pname = "sabaki";
  version = "0.52.2";
  src = fetchurl {
    url = "https://github.com/SabakiHQ/Sabaki/releases/download/v${version}/sabaki-v${version}-linux-x64.AppImage";
    sha256 = "sha256-wuCj5HvNZc2KOdc5O49upNToFDKiMMWexykctHi51EY=";
  };
  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "Sabaki";
    genericName = "Sabaki";
    comment = "SGF Editor";
    categories = [ "Utility" ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [
    ffmpeg
    chromium
    swiftshader
    vulkan-loader
    xorg.libxshmfence
    libGL
  ];

  extraInstallCommands = ''
    # Extract and install icon
    source="${appimageTools.extract { inherit pname version src; }}"
    install -m 444 -D $source/sabaki.png $out/share/icons/hicolor/512x512/apps/${pname}.png

    # Install desktop entry
    install -Dm644 ${desktopItem}/share/applications/*.desktop $out/share/applications/${pname}.desktop
  '';
}
