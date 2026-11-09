{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  cmake,
  perl,
}: let
  rev = "049a4c86eb407030a491bed5723a44f27e11da5e";
  version = "release-1.2.4-unstable-2026-11-09";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    inherit rev;
    hash = "sha256-IXnZpJ13TBn8x8R0xw91kRR9GRDFfle8WXevIM8HjC0=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent-nightly";
    inherit version src;

    cargoHash = "sha256-pafKxmxsBIxnr8wj7djhnenbOOhRxb56J+vec4YbHJw=";

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
