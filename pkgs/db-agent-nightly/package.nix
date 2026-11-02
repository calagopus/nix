{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  cmake,
  perl,
}: let
  rev = "10fc4dba0c63b4adb668f3c9780f2fef15e879d4";
  version = "release-1.2.4-unstable-2026-11-02";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    inherit rev;
    hash = "sha256-Q1w822n69tJ710KptLc3ZMGpeoOLHgU4zKnqKTloi+U=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent-nightly";
    inherit version src;

    cargoHash = "sha256-LLyyQQBlO0VH09E/oXwmqEyerY0Wpgrq3/OMoEScD5o=";

    # aws-lc-sys and zlib-ng are built from source
    nativeBuildInputs = [
      cmake
      perl
    ];

    # The upgrade tests build a reqwest client, which needs CA certificates
    nativeCheckInputs = [cacert];

    env = {
      CARGO_GIT_BRANCH = "main";
      CARGO_GIT_COMMIT = rev;
    };

    meta = {
      description = "High-performance database proxy and provisioning agent for PostgreSQL, MySQL, Redis and MongoDB (nightly build)";
      homepage = "https://calagopus.com";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "db-agent";
      platforms = lib.platforms.linux;
    };
  })
