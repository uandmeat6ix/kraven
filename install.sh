#!/usr/bin/env bash
#
#  Instalador de KRAVEN  (Hollywood remasterizado)
#  Copia el ejecutable a /usr/local/bin para poder llamarlo desde cualquier lado.
#
set -e

SRC="$(cd "$(dirname "$0")" && pwd)/kraven"
DEST="/usr/local/bin/kraven"

if ! command -v python3 >/dev/null 2>&1; then
  echo "[!] Falta python3. Instalalo con:  sudo apt update && sudo apt install -y python3"
  exit 1
fi

echo "[*] Instalando kraven en $DEST ..."
if [ -w "$(dirname "$DEST")" ]; then
  install -m 755 "$SRC" "$DEST"
else
  sudo install -m 755 "$SRC" "$DEST"
fi

echo "[+] Listo. Ejecuta:  kraven"
echo "    (o  kraven --fast  /  kraven --help )"
