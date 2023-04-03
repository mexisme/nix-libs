{
  description = "Some Nix libs";

  outputs = { self, nixpkgs, ... }@inputs: {
    importable = import ./importable;
    flakes = import ./flakes { inherit importable; };
  };
}
