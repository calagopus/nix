{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  cmake,
  perl,
}: let
  version = "1.2.3";
  src = fetchFromGitHub {
    owner = "calagopus";
    repo = "db-agent";
    rev = "release-${version}";
    hash = "sha256-kY6QhWJwHgycUWPhyh06BCn/0xV4juJp+Rcdsp91Syk=";
  };
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "calagopus-db-agent";
    inherit version src;

    cargoHash = "sha256-XTfsytk5dZBGmdFaHMj+uVQX+dZ+ktJ8dBM9nC7kZrA=";

    # aws-lc-sys and zlib-ng are built from source
    nativeBuildInputs = [
      cmake
      perl
    ];

    # The upgrade tests build a reqwest client, which needs CA certificates
    nativeCheckInputs = [cacert];

    env = {
      CARGO_GIT_BRANCH = "unknown";
      CARGO_GIT_COMMIT = "unknown";
    };

    meta = {
      description = "High-performance database proxy and provisioning agent for PostgreSQL, MySQL, Redis and MongoDB";
      homepage = "https://calagopus.com";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "db-agent";
      platforms = lib.platforms.linux;
    };
  })
