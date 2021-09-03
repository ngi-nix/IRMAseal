## IRMAseal

This flake packages the [IRMAseal]() set of packages.
Included are:

 - `irmaseal-cli`
 - `irmaseal-pkg`

### IRMAseal-cli

Command-line application that serves all IRMAseal
operations, including IRMA attribute disclosure proofs. This
flake provides `irmaseal-cli` as a package:

```
nix build github:ngi-nix/irmaseal#irmaseal-cli

./result/bin/irmaseal-cli -V
irmaseal-cli 0.1
```

### IRMAseal-pkg

The *Private Key Generator*, an HTTP REST service that
receives attribute disclosure proofs and yields the
corresponding user secret key. This flake provides
IRMAseal-pkg as a package as well as a module. 

To use IRMAseal-pkg as a standalone package:
```
nix build github:ngi-nix/irmaseal#irmaseal-pkg

# the standalone package can be used to generate keys
./result/bin/irmaseal-pkg generate
Written ./pkg.pub and ./pkg.sec

# it can also be used to run the HTTP service
./result/bin/irmaseal-pkg server
```

To use IRMAseal-pkg as a module:

```
# in /etc/nixos/configuration.nix
{
  imports = [
    (builtins.getFlake "github:ngi-nix/irmaseal").nixosModules.irmaseal-pkg
  ];
  
  services.irmaseal-pkg.enable = true;
}
```

## Future work

Code belonging to IRMAseal clients for mailclient are not
are still a work in progress and should be included in this
flake when ready.
