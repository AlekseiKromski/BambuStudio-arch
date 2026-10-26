#!/bin/bash
set -eo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

configure_parallel_jobs() {
    if [ -n "${JOBS:-}" ]; then
        export CMAKE_BUILD_PARALLEL_LEVEL="${JOBS}"
    else
        local free_mem_gb
        free_mem_gb=$(free -g -t | awk '/^Mem:/ {print $NF}')
        local max_threads=$(( free_mem_gb * 10 / 25 ))
        if [ "${max_threads}" -lt 1 ]; then
            max_threads=1
        fi
        export CMAKE_BUILD_PARALLEL_LEVEL="${max_threads}"
    fi
    echo "==> Using CMAKE_BUILD_PARALLEL_LEVEL=${CMAKE_BUILD_PARALLEL_LEVEL}"
}

build_deps() {
    configure_parallel_jobs
    echo "==> Configuring & building static dependencies (deps/)..."
    cmake -S deps -B deps/build -G Ninja \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DDEP_WX_GTK3=ON \
        -DCMAKE_BUILD_TYPE=Release
    cmake --build deps/build
}

build_app() {
    configure_parallel_jobs
    echo "==> Updating version date in version.inc..."
    sed -i "s/+UNKNOWN/_$(date '+%F')/" version.inc

    export PKG_CONFIG_PATH="${ROOT_DIR}/deps/build/destdir/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

    echo "==> Configuring & building BambuStudio..."
    cmake -S . -B build -G Ninja \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DCMAKE_PREFIX_PATH="${ROOT_DIR}/deps/build/destdir/usr/local" \
        -DSLIC3R_STATIC=1 \
        -DSLIC3R_GTK=3 \
        -DSLIC3R_PCH=OFF \
        -DCMAKE_CXX_FLAGS="-g0 --param ggc-min-expand=10 --param ggc-min-heapsize=32768" \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-keep-memory" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBBL_RELEASE_TO_PUBLIC=1 \
        -DBBL_INTERNAL_TESTING=0
    cmake --build build --target BambuStudio
}

build_package() {
    echo "==> Preparing PKGBUILD and building .pkg.tar.zst..."
    local pkgver
    pkgver=$(sed -n 's/^set(SLIC3R_VERSION "\(.*\)")/\1/p' "${ROOT_DIR}/version.inc" | tr -d '[:space:]' | tr '-' '_')

    mkdir -p /home/packager/pkg
    sed "s/@PKGVER@/${pkgver}/g" "${ROOT_DIR}/arch/PKGBUILD" > /home/packager/pkg/PKGBUILD
    chown -R packager:packager /home/packager/pkg

    su - packager -c "cd /home/packager/pkg && makepkg -d"
}

case "${1:-}" in
    deps)
        build_deps
        ;;
    app)
        build_app
        ;;
    package)
        build_package
        ;;
    *)
        echo "Usage: $0 {deps|app|package}"
        exit 1
        ;;
esac
