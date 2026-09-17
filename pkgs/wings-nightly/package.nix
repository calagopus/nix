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
  rev = "c3037a6e10a7b4a352e7f114b330fcd963484615";
  version = "release-1.2.1-unstable-2026-09-17";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "wings";
    inherit rev;
    sha256 = "sha256-50r3JjDSttHy5mh48vCVdR0l9Tm7ZA63R7i+T71bgvk=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-wings-nightly";
    inherit version src;

    cargoHash = "sha256-lj7sf6FvZBX4gGuvpH9rOv4jbft9dgQ+cnEF8eSDw/U=";

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
