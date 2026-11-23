{
  lib,
  cacert,
  fetchFromGitHub,
  rustPlatform,
  fusequota,
  autoPatchelfHook,
  stdenv,
  perl,
  pkg-config,
  cmake,
  openssl,
  libssh2,
  zlib,
  aws-lc,
  sqlite,
  zstd,
  rust-jemalloc-sys,
}: let
  # Latest main branch commit
  rev = "fde0a71b7f74d2691e4d2b228a781e27c01e8a9f";
  version = "release-1.2.11-unstable-2026-11-23";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "wings";
    inherit rev;
    sha256 = "sha256-0HPsrnAQ9bK5vh39o9/V2UApdwCCo2UZs0Y8gFFw5Vk=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-wings-nightly";
    inherit version src;

    cargoHash = "sha256-pFLaiJlsy08/qRm0qzX6O45dvM+1AQ8v+cuOndhUbdk=";

    nativeBuildInputs = [
      autoPatchelfHook
      perl
      pkg-config
      cmake
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      openssl
      libssh2
      zlib
      # cargoSetupHook makes the -sys crates link these instead of vendoring
      aws-lc
      sqlite
      zstd
      rust-jemalloc-sys
    ];

    cargoBuildFlags = ["-p" "wings-rs"];

    nativeCheckInputs = [cacert];

    # no inotify in the sandbox
    checkFlags = ["--skip=server::filesystem::inotify::tests"];

    # autoPatchelfHook only runs in postFixup, so the test binaries cargo builds
    # during checkPhase are still unpatched and cannot find libstdc++.so.6.
    preCheck = ''
      export LD_LIBRARY_PATH=${lib.makeLibraryPath [stdenv.cc.cc.lib]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    '';

    env =
      {
        CARGO_GIT_BRANCH = "main";
        CARGO_GIT_COMMIT = rev;
      }
      // lib.optionalAttrs stdenv.hostPlatform.isLinux {
        # build.rs embeds a fusequota binary in wings, downloading one from
        # GitHub releases if it has to, and refuses to build on linux without
        # one. There is no network in the sandbox, so hand it ours.
        FUSEQUOTA_BINARY_PATH = lib.getExe fusequota;
        FUSEQUOTA_RELEASE = fusequota.version;
      };

    meta = {
      description = "Pterodactyl Wings alternative written in Rust — faster, more features, more maintainable (nightly build)";
      homepage = "https://calagopus.com";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "wings-rs";
      platforms = lib.platforms.linux;
    };
  })
