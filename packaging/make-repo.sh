#!/usr/bin/env bash
#
#  Crea un repositorio APT local para poder hacer  'apt install kraven'  a secas.
#  Uso:   ./make-repo.sh [version]
#  Requiere: dpkg-deb + dpkg-scanpackages (paquete dpkg-dev en Kali/Debian)
#
set -e

VERSION="${1:-1.0.0}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
REPO="$ROOT/dist/repo"

if ! command -v dpkg-scanpackages >/dev/null 2>&1; then
  echo "[!] Falta dpkg-scanpackages. Instalalo:  sudo apt install dpkg-dev"
  exit 1
fi

# 1) construir el .deb
"$HERE/build-deb.sh" "$VERSION"

# 2) armar el repo
mkdir -p "$REPO"
cp -f "$ROOT/dist/kraven_${VERSION}_all.deb" "$REPO/"
( cd "$REPO" && dpkg-scanpackages . /dev/null > Packages && gzip -kf Packages )

echo
echo "[+] Repositorio local listo en: $REPO"
echo
echo "Para habilitarlo y usar 'apt install kraven':"
echo "  echo \"deb [trusted=yes] file://$REPO ./\" | sudo tee /etc/apt/sources.list.d/kraven.list"
echo "  sudo apt update"
echo "  sudo apt install kraven"
echo
echo "Para quitarlo despues:"
echo "  sudo rm /etc/apt/sources.list.d/kraven.list && sudo apt update"
