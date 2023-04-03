{ importable,
}:

let
  # TODO: Support ARM:
  systems = [
    "x86_64-linux"
    "i686-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  forAllSystems = f:
    builtins.listToAttrs (
      map (name: { inherit name; value = f name; }) systems
    );

  checks = import ./checks.nix;

  nixpkgs-builder = import ./nixpkgs-builder.nix { inherit checks; };

  package-set = import ./package-set.nix { inherit importable; };

  nixpkgs-combined = { inputs, system }:
    forAllSystems (system: nixpkgs-builder { inherit inputs system; });

in {
  inherit systems forAllSystems checks nixpkgs-builder package-set nixpkgs-combined;
}
