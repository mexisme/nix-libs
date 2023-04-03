{
  description = "Some Nix libs";

  outputs = { self, nixpkgs, ... }@inputs:
    let
      importable = import ./importable;
      flakes = import ./flakes { inherit importable; };
    in {
      inherit importable flakes;
  };
}
