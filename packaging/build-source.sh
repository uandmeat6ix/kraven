#!/usr/bin/env bash
#
#  Construye el PAQUETE FUENTE Debian (lo que revisa Debian/Kali):
#  genera el tarball upstream .orig.tar.gz y corre dpkg-buildpackage.
#
#  Uso:   ./build-source.sh [version]     (por defecto 1.0.0)
#  Requiere (en Kali/Debian):
#     sudo apt install build-essential debhelper devscripts lintian
#
set -e

VERSION="${1:-1.0.0}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

for t in dpkg-buildpackage dh lintian; do
  command -v "$t" >/dev/null 2>&1 || {
    echo "[!] Falta '$t'. Instala:  sudo apt install build-essential debhelper devscripts lintian"
    exit 1
  }
done

cd "$ROOT"

# 1) tarball upstream (sin debian/, sin artefactos locales)
echo "[*] Generando ../kraven_${VERSION}.orig.tar.gz ..."
tar czf "../kraven_${VERSION}.orig.tar.gz" \
    --exclude=./debian \
    --exclude=./dist \
    --exclude=./packaging \
    --exclude-vcs \
    .

# 2) construir binario + fuente firmables
echo "[*] dpkg-buildpackage ..."
dpkg-buildpackage -us -uc

# 3) chequeo de calidad
echo
echo "[*] lintian:"
lintian --info --display-info "../kraven_${VERSION}-1_all.deb" || true

echo
echo "[+] Artefactos en el directorio superior:"
echo "    ../kraven_${VERSION}-1_all.deb          (paquete instalable)"
echo "    ../kraven_${VERSION}-1.dsc              (descriptor fuente)"
echo "    ../kraven_${VERSION}.orig.tar.gz        (tarball upstream)"
echo "    ../kraven_${VERSION}-1_source.changes   (para subir a mentors/Kali)"
