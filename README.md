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

This repository includes a self-contained Docker build pipeline (`arch.Dockerfile`, `arch/build.sh`, and `arch/PKGBUILD`) that compiles Bambu Studio inside an isolated `archlinux:base-devel` container and exports a native `pacman` installer package (`bambu-studio-<version>-1-x86_64.pkg.tar.zst`) without installing any build-time compilers or `-dev` libraries on your host machine.

### 1. Build the `.pkg.tar.zst` Installer
From the repository root, run:
```bash
DOCKER_BUILDKIT=1 docker build -f arch.Dockerfile -o type=local,dest=./out .
```
* **Parallel jobs / RAM control:** By default, `arch/build.sh` automatically limits parallel compilation threads based on available system RAM (~2.5 GB per thread). To override the thread count manually, pass `--build-arg JOBS=<N>`:
  ```bash
  DOCKER_BUILDKIT=1 docker build -f arch.Dockerfile --build-arg JOBS=4 -o type=local,dest=./out .
  ```
* **Output:** When the build finishes, the native Arch package will be saved in `./out/bambu-studio-<version>-1-x86_64.pkg.tar.zst`.

### 2. Install, Update, or Uninstall via `pacman`
* **Install or Upgrade:**
  ```bash
  sudo pacman -U ./out/bambu-studio-*.pkg.tar.zst
  ```
  `pacman` will automatically resolve and install any missing runtime dependencies, register the desktop launcher and icons, and associate `.3mf`/`.stl` files. When upgrading from an older version, `pacman -U` cleanly replaces the previous package while leaving your user profiles and settings in `~/.config/BambuStudio` untouched.
* **Uninstall:**
  ```bash
  sudo pacman -R bambu-studio
  ```

### 3. How to Maintain & Update to a New Stable Release
The `arch-stable` branch sits directly on top of an official stable release tag (e.g., `v02.08.02.61`) with two custom commits:
1. `fix(linux): remove obsolete OSMesa link target for Arch Linux`
2. `feat(arch): add Docker .pkg.tar.zst builder and maintenance docs`

When Bambu Lab publishes a new stable release tag on GitHub (for example, `v02.09.00.50`):

1. **Fetch the latest tags from the official upstream repository:**
   ```bash
   # Add upstream once if you haven't already:
   git remote add upstream https://github.com/bambulab/BambuStudio.git

   # Fetch all new release tags:
   git fetch upstream --tags
   ```
2. **Rebase your custom `arch-stable` commits onto the new stable tag:**
   ```bash
   # Replace v02.08.02.61 with your current base tag, and v02.09.00.50 with the new stable tag:
   git rebase --onto v02.09.00.50 v02.08.02.61 arch-stable
   ```
   *(Alternatively, you can reset `arch-stable` to the new tag and cherry-pick the two commits: `git checkout -B arch-stable v02.09.00.50 && git cherry-pick <commit1> <commit2>`).*
3. **Tag and push to your fork (optional):**
   ```bash
   git tag v02.09.00.50-arch
   git push origin arch-stable --force-with-lease --tags
   ```
4. **Build and install the updated package:**
   ```bash
   rm -rf ./out
   DOCKER_BUILDKIT=1 docker build -f arch.Dockerfile -o type=local,dest=./out .
   sudo pacman -U ./out/bambu-studio-*.pkg.tar.zst
   ```
   *(Note: Because `arch.Dockerfile` caches the `deps/` build in a separate Docker layer, Docker will automatically reuse the compiled dependencies layer if `deps/` did not change between releases).*

# Report issue
You can add an issue to the [github tracker](https://github.com/bambulab/BambuStudio/issues) if **it isn't already present.**

# License
Bambu Studio is licensed under the GNU Affero General Public License, version 3. Bambu Studio is based on PrusaSlicer by PrusaResearch.

PrusaSlicer is licensed under the GNU Affero General Public License, version 3. PrusaSlicer is owned by Prusa Research. PrusaSlicer is originally based on Slic3r by Alessandro Ranellucci.

Slic3r is licensed under the GNU Affero General Public License, version 3. Slic3r was created by Alessandro Ranellucci with the help of many other contributors.

The GNU Affero General Public License, version 3 ensures that if you use any part of this software in any way (even behind a web server), your software must be released under the same license.

The bambu networking plugin is based on non-free libraries. It is optional to the Bambu Studio and provides extended networking functionalities for users.
By default, after installing Bambu Studio without the networking plugin, you can initiate printing through the SD card after slicing is completed.

