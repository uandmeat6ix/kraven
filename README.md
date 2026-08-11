# KRAVEN — Hollywood, remasterizado 💀

Una pantalla de "hackeo" de película para la terminal, al estilo del paquete
[`hollywood`](https://packages.debian.org/hollywood) de Kali… pero remasterizada:
un dashboard multipanel con lluvia Matrix, escaneo de puertos, exploits, fuerza
bruta, exfiltración de datos y el clásico **ACCESS GRANTED**.

> ⚠️ Es **100% teatro**. No escanea, no explota, no toca la red: solo dibuja
> texto bonito. Ideal para trollear, ambientar una charla, un stream o un video.

Solo necesita **python3** (librería estándar). Nada de `pip install`.

---

## Instalar en Kali (o cualquier Debian/Ubuntu)

```bash
cd kraven
chmod +x kraven install.sh
sudo ./install.sh
```

Eso lo deja como comando global. Luego, desde cualquier lado:

```bash
kraven
```

### Sin instalar (ejecución directa)

```bash
python3 kraven
```

---

## Instalar como paquete (`apt` / `.deb`)

### A) Construir el `.deb` e instalarlo

```bash
cd packaging
./build-deb.sh            # genera ../dist/kraven_1.0.0_all.deb
sudo apt install ../dist/kraven_1.0.0_all.deb
# (equivalente: sudo dpkg -i ../dist/kraven_1.0.0_all.deb)
```

`apt` resuelve la dependencia `python3` y lo deja como comando `kraven`.
Para desinstalar: `sudo apt remove kraven`.

### B) `apt install kraven` a secas (repo APT local)

Para que funcione **sin ruta**, hay que publicarlo en un repositorio APT.
El script `make-repo.sh` arma uno local:

```bash
cd packaging
./make-repo.sh            # construye el .deb y un repo en ../dist/repo

# habilitar el repo (una sola vez):
echo "deb [trusted=yes] file://$(cd ../dist/repo && pwd) ./" \
  | sudo tee /etc/apt/sources.list.d/kraven.list
sudo apt update
sudo apt install kraven
```

Para quitar el repo: `sudo rm /etc/apt/sources.list.d/kraven.list && sudo apt update`.

> Un `apt install kraven` **global** (que le funcione a cualquiera sin agregar
> el repo) exige hospedar el repositorio en un servidor y firmarlo con GPG.
> El repo local de arriba es el mismo mecanismo, servido desde tu disco.

> Requisitos de build: `dpkg-deb` (paquete `dpkg`) y, para el repo,
> `dpkg-scanpackages` (paquete `dpkg-dev`). Ambos vienen en Kali/Debian.

---

## Subir a GitHub (y habilitar `apt install kraven` vía GitHub Pages)

Esta es la forma más rápida de que **cualquiera** lo instale sin depender de
los repos oficiales de Kali/Debian: tu propio repositorio APT hospedado gratis
en GitHub Pages, construido automáticamente por GitHub Actions.

### 1) Crear el repo y subir el código

```bash
# desde la carpeta kraven/
git init -b main
git add .
git commit -m "kraven 1.0.0 - apex intrusion suite (Hollywood, remastered)"

# crear el repo en tu cuenta (requiere la CLI 'gh' autenticada):
gh repo create kraven --public --source=. --remote=origin --push
# ...o hazlo a mano en github.com y luego:
#   git remote add origin https://github.com/uandmeat6ix/kraven.git
#   git push -u origin main
```

### 2) Publicar una versión

El workflow [`.github/workflows/publish.yml`](.github/workflows/publish.yml) se
dispara al empujar un tag:

```bash
git tag v1.0.0
git push --tags
```

Eso construye el `.deb`, lo adjunta al **Release** de GitHub y publica un
repositorio APT en la rama `gh-pages`. Habilita Pages una vez:
**Settings → Pages → Source: `gh-pages`**.

### 3) Instalarlo (lo que corre cualquier usuario)

**Opción rápida — bajar el `.deb` del Release:**

```bash
curl -LO https://github.com/uandmeat6ix/kraven/releases/latest/download/kraven_1.0.0_all.deb
sudo apt install ./kraven_1.0.0_all.deb
```

**Opción `apt install kraven` de verdad — añadir tu repo APT:**

```bash
echo "deb [trusted=yes] https://uandmeat6ix.github.io/kraven ./" \
  | sudo tee /etc/apt/sources.list.d/kraven.list
sudo apt update
sudo apt install kraven
```

**Opción sin paquete — clonar y usar `install.sh`:**

```bash
git clone https://github.com/uandmeat6ix/kraven.git
cd kraven && sudo ./install.sh
```

> `[trusted=yes]` omite la verificación GPG (simple y funciona). Para
> endurecerlo, firma el repo con una clave GPG (guardada como *secret* del repo)
> y publica el `Release.gpg`/`InRelease`; entonces los usuarios importan tu
> clave pública en vez de usar `[trusted=yes]`.

---

## Publicar en los repositorios de Kali (para que *cualquiera* lo instale)

> **Importante:** a los repos de Kali **no se sube** libremente. Son *curados*:
> el equipo de Kali (o de Debian) revisa y acepta el paquete. Lo que subes es
> un **paquete fuente** para revisión, no un `.deb` a un servidor abierto.

Este repo ya trae el empaquetado fuente listo en `debian/` (control, rules,
changelog, copyright DEP-5, man page, watch). Construye el paquete fuente con:

```bash
cd packaging
./build-source.sh          # crea ../kraven_1.0.0.orig.tar.gz, .dsc y _source.changes
```

Antes de enviarlo, ajusta:

- **`debian/control`** y **`debian/copyright`**: pon tu **nombre real** en
  `Maintainer` (Debian exige nombre real, no el alias "Jarthur").
- **`debian/changelog`**: distribución `unstable` para Debian, o `kali-dev`
  para Kali.
- **`LICENSE` / `debian/copyright`**: confirma la licencia (aquí, MIT).

### Ruta 1 — vía Debian (llega a Kali "gratis")

Kali *deriva* de Debian: casi todo lo que entra a Debian aparece luego en
kali-rolling. Novedades de terminal como `hollywood`, `cmatrix` o `sl`
entraron así.

1. Publica el código en un repo git público con *tags* de versión.
2. Abre un **ITP** (Intent To Package) contra el pseudo-paquete `wnpp`
   (`reportbug wnpp`).
3. Sube el paquete fuente a **mentors.debian.net**.
4. Consigue un **sponsor** (un Debian Developer) que lo revise y lo suba a la
   cola **NEW**; ftp-masters revisan licencia/copyright.
5. Al aceptarse entra en *unstable*, migra a *testing*, y Kali lo recoge.

Es el camino de mayor alcance pero lento (semanas/meses) y estricto.

### Ruta 2 — directo a Kali

1. Ten el código en un repo git público, con licencia libre y releases.
2. Abre una **solicitud de nueva herramienta / paquete** en el GitLab de Kali
   (`gitlab.com/kalilinux`). Consulta la guía oficial vigente en
   **kali.org/docs/development/** ("Making / Submitting a Kali Package") y las
   plantillas de *issue* para peticiones de herramientas.
3. El equipo de Kali evalúa si encaja (utilidad, mantenimiento, licencia) y,
   si lo aceptan, lo empaquetan en su infraestructura.

### Chequeo de calidad (obligatorio antes de enviar)

```bash
lintian -I --pedantic ../kraven_1.0.0-1_source.changes
```

Debe salir limpio (o con warnings justificados). Los repos rechazan paquetes
con errores de `lintian`.

> Realidad esperable: al ser una utilidad "de broma" (aunque con precedentes
> como `hollywood`), lo más probable es que te pidan que primero viva en un
> repo público con tracción, y la vía Debian suele ser la que termina llevándolo
> a Kali. No hay un botón de "subir y listo".

---

## Uso

```bash
kraven            # arranca la simulación
kraven --fast     # sin efecto de tipeo, ritmo acelerado
kraven --frames N # renderiza N frames y sale (pruebas / grabaciones)
kraven --help     # ayuda
```

### Teclas en vivo

| Tecla            | Acción                                            |
|------------------|---------------------------------------------------|
| cualquier tecla  | inyecta una línea de "código" (modo hacker-typer) |
| `ESPACIO`        | pausa / reanuda                                    |
| `q` / `Ctrl+C`   | salir (restaura la terminal)                       |

**Tip:** ponla en pantalla completa (o `tmux`/consola sin barras), teclea como
poseído y deja que corra en loop.

---

## Qué muestra

- **shell** — terminal que teclea comandos verosímiles (`nmap`, `msfconsole`
  con EternalBlue, `hydra`, DirtyPipe/PwnKit…).
- **datastream** — lluvia Matrix animada.
- **target vitals · telemetry** — datos del objetivo + medidores CPU/MEM/NET/GPU/CRYPT.
- **port sweep** — barrido de puertos con CVEs en rojo y contador hacia 65535.
- **exfil** — hexdump corriendo en tiempo real.
- **barra de misión** — progreso por fases: RECON → FINGERPRINT → EXPLOIT →
  BRUTE FORCE → PRIVESC → EXFIL → CLEANUP → **ACCESS GRANTED** → y vuelve a empezar.

El layout se adapta al tamaño de la terminal (mínimo 74×20).

---

## Bonus: “Kiosco” / autoarranque

Para que arranque sola en una consola (efecto sala de control):

```bash
# en ~/.bashrc de una tty dedicada, por ejemplo
kraven
```

Para grabar un GIF/vídeo bonito, combínalo con `asciinema` o `ttygif`.
