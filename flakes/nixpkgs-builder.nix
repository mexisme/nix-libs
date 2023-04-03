{ checks,
}:

{ system,
  inputs,
}:

let
  inherit (checks { inherit system; }) isDarwin;

  # build = { nixpkgs, system, overlays ? [] }: nixpkgs.legacyPackages.${system};

  # This is the only way to override "allowUnfree".  The "legacyPackages" version will ignore it?
  build = { nixpkgs, system, overlays ? [] }:
    import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
      # config.allowBroken = true;
    };

  pkgs-alt = with inputs;
    {
      master = build { inherit system; nipkgs = nixpkgs-master; };
      unstable = build { inherit system; nixpkgs = nixpkgs-unstable; };
    };

  nixpkgs' = with inputs;
    if isDarwin
    then build { inherit system nixpkgs; }
    else build { inherit system; nixpkgs = nixpkgs-darwin; };

in nixpkgs' // { inherit pkgs-alt; }
