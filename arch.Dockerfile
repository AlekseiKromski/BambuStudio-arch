FROM archlinux:base-devel AS builder

ARG JOBS=""
ENV JOBS="${JOBS}"

RUN pacman -Syu --noconfirm \
    git wget unzip file cmake ninja extra-cmake-modules \
    autoconf automake libtool gettext texinfo nasm yasm \
    wayland-protocols eglexternalplatform \
    gtk3 webkit2gtk-4.1 gstreamer gst-plugins-base \
    libsecret libmspack glew glu mesa libxkbcommon \
    curl openssl dbus bzip2 x264 && \
    useradd -m packager

WORKDIR /BambuStudio

# Step 1: Build static dependencies (cached unless deps/ or cmake/ changes)
COPY cmake /BambuStudio/cmake
COPY deps /BambuStudio/deps
COPY arch/build.sh /BambuStudio/arch/build.sh
RUN chmod +x /BambuStudio/arch/build.sh && /BambuStudio/arch/build.sh deps

# Step 2: Build BambuStudio application
COPY . /BambuStudio
RUN chmod +x /BambuStudio/arch/build.sh && /BambuStudio/arch/build.sh app

# Step 3: Package into .pkg.tar.zst
RUN /BambuStudio/arch/build.sh package

# Step 4: Export only the finished .pkg.tar.zst installer to host
FROM scratch AS export-stage
COPY --from=builder /home/packager/pkg/*.pkg.tar.zst /
