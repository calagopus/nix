# Calagopus Nix
Nix packages and modules for Calagopus

# Packages outputted
- **panel** - Latest stable version of the panel
- **panel-nightly** Nightly version of the panel built from commits on the main branch
- **wings** Latest stable version of wings
- **wings-nightly** Nightly version of wings built from commits on the main branch

All packages are updated automatically (either version or commit bump) every six hours. You can see the updates [here](https://github.com/Saturn745/calagopus-nix/actions/workflows/update.yml)

# Binary Cache
We have a binary cache hosted with [Cachix](https://cachix.org) where all versions of packages are automatically pushed to so you don't need to build them yourself if you don't want to.

```nix
    extra-substituters = ["https://calagopus-nix.cachix.org"];
    extra-trusted-public-keys = [
      "calagopus-nix.cachix.org-1:KnwFwKiw7rgY2depzwWWiPmLdW1gL5DfZKNTcUcB0oo="
    ];
```

# Panel deployment
To deploy the panel on NixOS we ship an easy-to-use NixOS module. An example can be found in the test VM [here](https://github.com/Saturn745/calagopus-nix/blob/master/flake.nix#L118-L125)

#### Extensions
Not possible at the moment. Looking into how best to do this.

# Wings deployment
TODO

### Currently you need to manually write your own service for it. A NixOS module will be added soon

