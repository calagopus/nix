{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
  pkg-config,
  liburing,
  mimalloc,
}: let
  # Upstream cuts a release per commit on main, tagged with the short commit
  # hash: https://github.com/calagopus/fusequota/releases
  rev = "ad0b35fc2cadb3ce487ab7c4fa2a5b06aece1cfb";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "fusequota";
    version = "9919455-unstable-2026-11-10";

    src = fetchFromGitHub {
      owner = "calagopus";
      repo = "fusequota";
      inherit rev;
      # libfuse is vendored as a submodule, and patched during configure
      fetchSubmodules = true;
      hash = "sha256-DefHWn4MpkOVRmlBrpd+J5ODA+/gwzbHfcyFfzp3BMU=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      cmake
      meson
      ninja
      pkg-config
    ];

    buildInputs = [
      liburing
      mimalloc
    ];

    # Everything is linked statically because wings embeds this binary and
    # extracts it onto an arbitrary host at runtime. Driving the phases by hand
    # keeps the cmake, meson and ninja setup hooks from fighting over them, and
    # upstream has no install target to hook into anyway.
    configurePhase = ''
      runHook preConfigure

      patch -p1 -d external/libfuse -i ../../patches/libfuse-fixes.patch

      # CMakeLists.txt expects the patched libfuse to sit in the source tree and
      # picks it up through its meson-uninstalled pkg-config file.
      (
        # libfuse is built with LTO, and slim LTO objects only contribute
        # symbols to the archive index if ar loads the LTO plugin. Plain ar
        # does not, which leaves the fusequota link with undefined references
        # to every fuse_* symbol; gcc-ar loads it.
        export AR="${stdenv.cc.cc}/bin/${stdenv.cc.targetPrefix}gcc-ar"
        export RANLIB="${stdenv.cc.cc}/bin/${stdenv.cc.targetPrefix}gcc-ranlib"

        meson setup external/libfuse external/libfuse/build \
          --default-library=static \
          --prefix=$out \
          -Db_lto=true \
          -Dexamples=false \
          -Dtests=false \
          -Dutils=false
        ninja -C external/libfuse/build
      )

      cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS="-O2 -ffunction-sections -fdata-sections" \
        -DCMAKE_EXE_LINKER_FLAGS="-static -static-libstdc++ -static-libgcc -Wl,--gc-sections"

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      cmake --build build -j $NIX_BUILD_CORES
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 build/fusequota $out/bin/fusequota
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      $out/bin/fusequota --help > /dev/null
      runHook postInstallCheck
    '';

    passthru.rev = rev;

    meta = {
      description = "FUSE-based disk quota system built for speed and compatibility";
      homepage = "https://github.com/calagopus/fusequota";
      license = lib.licenses.gpl2Only;
      maintainers = [];
      mainProgram = "fusequota";
      platforms = lib.platforms.linux;
    };
  })
