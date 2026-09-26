#!/bin/sh
# Polish a built Linux package tree in place.
#
# Tauri's freedesktop template emits `Categories=` with nothing after it, which
# violates the Desktop Entry specification and leaves the launcher uncategorised
# in most menus. It also ships no AppStream metadata, so software centres have
# nothing to show, and the AppImage root carries both `Cline.png` and a
# `cline-app.png` symlink pointing at the 32x32 icon.
#
# Usage: polish-linux-tree.sh <root>   (root is the AppDir / package root)
set -eu

ROOT="${1:?usage: polish-linux-tree.sh <root>}"
DESKTOP_DIR="$ROOT/usr/share/applications"
DESKTOP="$DESKTOP_DIR/Cline.desktop"

[ -d "$DESKTOP_DIR" ] || { echo "no applications dir in $ROOT" >&2; exit 1; }
[ -f "$DESKTOP" ] || { echo "no Cline.desktop in $DESKTOP_DIR" >&2; exit 1; }

cat > "$DESKTOP" <<'EOF'
[Desktop Entry]
Name=Cline
GenericName=AI Coding Agent
Comment=AI coding agent that plans, edits and runs code in your workspace
Categories=Development;IDE;
Exec=cline-app
Icon=cline-app
Terminal=false
Type=Application
StartupNotify=true
StartupWMClass=cline-app
X-AppImage-Name=Cline
X-AppImage-Version=0.0.32
EOF
echo "  desktop: wrote Categories=Development;IDE;"

METAINFO_DIR="$ROOT/usr/share/metainfo"
mkdir -p "$METAINFO_DIR"
cat > "$METAINFO_DIR/cline-app.metainfo.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>cline-app</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>Apache-2.0</project_license>
  <name>Cline</name>
  <summary>AI coding agent for your workspace</summary>
  <url type="homepage">https://github.com/10xdev4u-alt/cline</url>
  <url type="bugtracker">https://github.com/10xdev4u-alt/cline/issues</url>
  <url type="vcs-browser">https://github.com/10xdev4u-alt/cline</url>
  <description>
    <p>
      Cline is an AI coding agent that plans, edits and runs code directly in
      your workspace. It reads your project, proposes changes, applies them, and
      can execute commands on your behalf so you stay in control of every step.
    </p>
    <p>
      This is the Linux build, packaged as a self-contained AppImage or deb. It
      ships a local sidecar service that the interface connects to, so the agent
      backend starts alongside the window and requires no separate system
      install.
    </p>
    <p>
      Model usage goes through the provider of your choice. The app itself is
      free and open source.
    </p>
  </description>
  <launchable type="desktop-id">Cline.desktop</launchable>
  <categories>
    <category>Development</category>
    <category>IDE</category>
  </categories>
  <keywords>
    <keyword>ai</keyword>
    <keyword>coding agent</keyword>
    <keyword>developer</keyword>
    <keyword>ide</keyword>
  </keywords>
  <provides>
    <binary>cline-app</binary>
  </provides>
  <content_rating type="oars-1.1"/>
  <releases>
    <release version="0.0.32" date="2026-09-20">
      <description>
        <p>First Linux desktop release, packaged as AppImage and deb.</p>
      </description>
    </release>
  </releases>
</component>
EOF
echo "  metainfo: added usr/share/metainfo/cline-app.metainfo.xml"

# AppDir root only: the AppImage exposes <IconName>.png and .DirIcon at the
# top level, and a 32x32 icon there is what file managers and launchers show.
if [ -d "$ROOT/usr/lib/x86_64-linux-gnu" ] && [ -f "$ROOT/usr/share/icons/hicolor/256x256@2/apps/cline-app.png" ]; then
  BIG="$ROOT/usr/share/icons/hicolor/256x256@2/apps/cline-app.png"
  rm -f "$ROOT/cline-app.png" "$ROOT/Cline.png" "$ROOT/.DirIcon"
  ln -sf usr/share/icons/hicolor/256x256@2/apps/cline-app.png "$ROOT/cline-app.png"
  ln -sf cline-app.png "$ROOT/.DirIcon"
  echo "  icons: root icon now resolves to 256x256"
fi

exit 0
