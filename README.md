![image](https://user-images.githubusercontent.com/106916061/179006347-497d24c0-9bd6-45b7-8c49-d5cc8ecfe5d7.png)
# BambuStudio
Bambu Studio is a cutting-edge, feature-rich slicing software.  
It contains project-based workflows, systematically optimized slicing algorithms, and an easy-to-use graphic interface, bringing users an incredibly smooth printing experience.

Prebuilt Windows, macOS 64-bit and Linux releases are available through the [github releases page](https://github.com/bambulab/BambuStudio/releases/).

Bambu Studio is based on [PrusaSlicer](https://github.com/prusa3d/PrusaSlicer) by Prusa Research, which is from [Slic3r](https://github.com/Slic3r/Slic3r) by Alessandro Ranellucci and the RepRap community.

See the [wiki](https://github.com/bambulab/BambuStudio/wiki) and the [documentation directory](https://github.com/bambulab/BambuStudio/tree/master/doc) for more information.

# What are Bambu Studio's main features?
Key features are:
- Basic slicing features & GCode viewer
- Multiple plates management
- Remote control & monitoring
- Auto-arrange objects
- Auto-orient objects
- Hybrid/Tree/Normal support types, Customized support
- multi-material printing and rich painting tools
- multi-platform (Win/Mac/Linux) support
- Global/Object/Part level slicing parameters

Other major features are:
- Advanced cooling logic controlling fan speed and dynamic print speed
- Auto brim according to mechanical analysis
- Support arc path(G2/G3)
- Support STEP format
- Assembly & explosion view
- Flushing transition-filament into infill/object during filament change

# How to compile
Following platforms are currently supported to compile:
- Windows 64-bit, [Compile Guide](https://github.com/bambulab/BambuStudio/wiki/Windows-Compile-Guide)
- Mac 64-bit, [Compile Guide](https://github.com/bambulab/BambuStudio/wiki/Mac-Compile-Guide)
- Linux, [Compile Guide](https://github.com/bambulab/BambuStudio/wiki/Linux-Compile-Guide)
  - currently we only provide linux appimages on [github releases](https://github.com/bambulab/BambuStudio/releases) for Ubuntu/Fedora, and a [flathub version](https://flathub.org/apps/com.bambulab.BambuStudio) can be used for all the linux platforms

## Arch Linux / EndeavourOS Packaging (`.pkg.tar.zst` via Docker)

Builds a native `pacman` package (`bambu-studio-<version>-1-x86_64.pkg.tar.zst`) inside an isolated `archlinux:base-devel` Docker container (`arch.Dockerfile`, `arch/build.sh`, `arch/PKGBUILD`).

### Key Arch Linux Adaptations
* **Removed Obsolete `OSMesa` Link Target:** Removed `OSMesa` from `src/slic3r/CMakeLists.txt` (no longer shipped in Arch's `mesa` package).
* **Parallel Job Control (`arch/build.sh`):** Supports `--build-arg JOBS=<N>` to cap parallel C++ compiler threads and prevent Out-Of-Memory (`SIGKILL`) crashes.
* **Isolated `XDG_DATA_HOME` Wrapper (`arch/PKGBUILD`):** Sets `XDG_DATA_HOME="${HOME}/.config/BambuStudio/xdg-data"` in `/usr/bin/bambu-studio` to prevent `gdk-pixbuf2` / `glycin` (`bwrap`) crashes on symlinked user icon themes.

### 1. Build the `.pkg.tar.zst` Installer
```bash
DOCKER_BUILDKIT=1 docker build -f arch.Dockerfile --build-arg JOBS=4 -o type=local,dest=./out .
```
* **How to calculate `JOBS`:** Each compiler thread uses **~3.5–4 GB of RAM** at peak (`JOBS = Available_RAM_GB / 4`, e.g. `16 GB → 4`, `24 GB → 6`, `32 GB → 8`). If using Docker Desktop, use the VM RAM limit set in *Settings → Resources*.
* **Output:** `./out/bambu-studio-<version>-1-x86_64.pkg.tar.zst`

### 2. Install, Run, or Uninstall
```bash
# Install or upgrade (preserves ~/.config/BambuStudio):
sudo pacman -U ./out/bambu-studio-*.pkg.tar.zst

# Run:
bambu-studio

# Uninstall:
sudo pacman -R bambu-studio
```

### 3. Maintain & Update to a New Stable Release
When Bambu Lab publishes a new stable release tag (e.g. `v02.09.00.50`):

```bash
# 1. Fetch upstream tags (add remote once with: git remote add upstream https://github.com/bambulab/BambuStudio.git)
git fetch upstream --tags

# 2. Rebase arch-stable commits onto the new release tag
git rebase --onto v02.09.00.50 v02.08.02.61 arch-stable

# 3. Tag and push to fork
git tag -a v02.09.00.50-arch -m "Bambu Studio v02.09.00.50 for Arch Linux"
git push origin arch-stable --force-with-lease
git push origin v02.09.00.50-arch

# 4. Build and install
rm -rf ./out
DOCKER_BUILDKIT=1 docker build -f arch.Dockerfile --build-arg JOBS=4 -o type=local,dest=./out .
sudo pacman -U ./out/bambu-studio-*.pkg.tar.zst
```

# Report issue
You can add an issue to the [github tracker](https://github.com/bambulab/BambuStudio/issues) if **it isn't already present.**

# License
Bambu Studio is licensed under the GNU Affero General Public License, version 3. Bambu Studio is based on PrusaSlicer by PrusaResearch.

PrusaSlicer is licensed under the GNU Affero General Public License, version 3. PrusaSlicer is owned by Prusa Research. PrusaSlicer is originally based on Slic3r by Alessandro Ranellucci.

Slic3r is licensed under the GNU Affero General Public License, version 3. Slic3r was created by Alessandro Ranellucci with the help of many other contributors.

The GNU Affero General Public License, version 3 ensures that if you use any part of this software in any way (even behind a web server), your software must be released under the same license.

The bambu networking plugin is based on non-free libraries. It is optional to the Bambu Studio and provides extended networking functionalities for users.
By default, after installing Bambu Studio without the networking plugin, you can initiate printing through the SD card after slicing is completed.

