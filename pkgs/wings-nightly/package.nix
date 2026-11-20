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
  rev = "6e1591b13a290f326726d902cecfb5079df2b53e";
  version = "release-1.2.10-unstable-2026-11-20";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "wings";
    inherit rev;
    sha256 = "sha256-AkThbiAQtEyEe3RPIN6h+0nRA0W9JEk3zwj69xmXYt8=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-wings-nightly";
    inherit version src;

    cargoHash = "sha256-WNrll+5lAGAZRX0CSc0stD68u02phH6tUsGUe0Tapx8=";

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
