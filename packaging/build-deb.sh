#!/usr/bin/env bash
#
#  Construye el paquete Debian  kraven_<version>_all.deb
#  Uso:   ./build-deb.sh [version]      (por defecto 1.0.0)
#  Requiere: dpkg-deb  (viene en cualquier Kali/Debian/Ubuntu)
#
set -e

VERSION="${1:-1.0.0}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

if ! command -v dpkg-deb >/dev/null 2>&1; then
  echo "[!] Falta dpkg-deb. Ejecuta esto en Kali/Debian (o: sudo apt install dpkg)."
  exit 1
fi

BUILD="$(mktemp -d)"
PKG="$BUILD/kraven"
mkdir -p "$PKG/DEBIAN" "$PKG/usr/bin" "$PKG/usr/share/doc/kraven"

install -m 755 "$ROOT/kraven"    "$PKG/usr/bin/kraven"
install -m 644 "$ROOT/README.md" "$PKG/usr/share/doc/kraven/README.md"
sed "s/^Version:.*/Version: $VERSION/" "$HERE/control" > "$PKG/DEBIAN/control"

OUT="$ROOT/dist"
mkdir -p "$OUT"
DEB="$OUT/kraven_${VERSION}_all.deb"

dpkg-deb --build --root-owner-group "$PKG" "$DEB"
rm -rf "$BUILD"

echo
echo "[+] Construido: $DEB"
echo "    Instalar:   sudo apt install \"$DEB\""
echo "    (o tambien: sudo dpkg -i \"$DEB\")"
