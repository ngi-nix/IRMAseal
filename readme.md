## IRMAseal

This flake packages the [IRMAseal]() set of packages.
Included are:

 - `irmaseal-cli`
 - `irmaseal-pkg`

If you are unfamiliar with Nix Flakes, consider looking
through the following:

 - [NixOS Wiki on Flakes](https://nixos.wiki/wiki/Flakes)
 - [Introduction to Flakes by Eelco Dolstra](https://www.tweag.io/blog/2020-05-25-flakes/)

### IRMAseal-cli

Command-line application that serves all IRMAseal
operations, including IRMA attribute disclosure proofs. This
flake provides `irmaseal-cli` as a package:

```
$ nix build github:ngi-nix/irmaseal#irmaseal-cli

$ ./result/bin/irmaseal-cli -h
irmaseal-cli 0.1
Wouter Geraedts <w.geraedts@sarif.nl>
Command line interface for IRMAseal, an Identity Based Encryption standard.

USAGE:
    irmaseal-cli [SUBCOMMAND]

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

SUBCOMMANDS:
    decrypt    decrypt a file
    encrypt    encrypt a file
    help       Prints this message or the help of the given subcommand(s)
```

### IRMAseal-pkg

The *Private Key Generator*, an HTTP REST service that
receives attribute disclosure proofs and yields the
corresponding user secret key. This flake provides
IRMAseal-pkg as a package as well as a module. 

#### Usage as standalone package

To use IRMAseal-pkg as a standalone package:
```
$ nix build github:ngi-nix/irmaseal#irmaseal-pkg

$ ./result/bin/irmaseal-pkg -h
irmaseal-pkg 0.1
Wouter Geraedts <w.geraedts@sarif.nl>
Private Key Generator (PKG) for IRMAseal, an Identity Based Encryption standard.

USAGE:
    irmaseal-pkg [SUBCOMMAND]

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

SUBCOMMANDS:
    generate    generate a global public/private keypair
    help        Prints this message or the help of the given subcommand(s)
    server      run the IRMAseal PKG HTTP server

# the standalone package can be used to generate keys
$ ./result/bin/irmaseal-pkg generate
Written ./pkg.pub and ./pkg.sec

# it can also be used to run the HTTP service
$ ./result/bin/irmaseal-pkg server
```

#### Usage as a module

To use IRMAseal-pkg as a module:

##### 1. (Optional) Generate keys 

The keys can be generated in one of two ways:

```
# get the package and run `irmaseal-pkg generate`
$ nix build github:ngi-nix/irmaseal#irmaseal-pkg
$ ./result/bin/irmaseal-pkg generate
Written ./pkg.pub and ./pkg.sec

# use the flake app!
$ nix run github:ngi-nix/irmaseal#generate-keys
Written ./pkg.pub and ./pkg.sec
```

##### 2. Enable the module

When enabling the module, pass the path to your generated
keys to the `keyDir` option. 

If this option is not provided, the keys are automatically
generated and placed in `/var/lib/irmaseal-pkg`.

If this option is provided and the keys are not present at
the directory, they are generated and placed in the same
directory.

```
# in /etc/nixos/configuration.nix
{
  imports = [
    (builtins.getFlake "github:ngi-nix/irmaseal").nixosModules.irmaseal-pkg
  ];
  
  services.irmaseal-pkg = {
    enable = true;

    # Path to the directory containing both private and
    # public key.
    #
    # If the keys are not present, they are generated on
    # the first run.
    keyDir = /path/to/your/keys;

    # see module for entire list of options
  };

}
```

## Future work

Code belonging to IRMAseal clients for mailclient are not
are still a work in progress and should be included in this
flake when ready.
