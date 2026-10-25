{
  lib,
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
}: let
  # Latest main branch commit
  rev = "3092c21cf52a9376d4582b163cd8e2403acc0a44";
  version = "release-1.2.7-unstable-2026-10-24";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "wings";
    inherit rev;
    sha256 = "sha256-OtWexozdkN4Wnnl7K/OaV/A+zlUdhK7bS+dAMJIwwHk=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-wings-nightly";
    inherit version src;

    cargoHash = "sha256-RH2ALlvTIhWkv0ZiFjjdyixSeonYXUGPJNKTsa+/o58=";

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
    ];

    cargoBuildFlags = ["-p" "wings-rs"];

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
