{ ... }: {
  imports = [
    (builtins.getFlake "path:./.").nixosModules.irmaseal-pkg
  ];
  services.irmaseal-pkg.enable = true;
}