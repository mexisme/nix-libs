{ checks,
}:

{ system,
  inputs,
  overlays ? [],
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
      master = build { inherit system overlays; nipkgs = nixpkgs-master; };
      unstable = build { inherit system overlays; nixpkgs = nixpkgs-unstable; };
    };

  nixpkgs' = with inputs;
    if isDarwin
    then build { inherit system overlays nixpkgs; }
    else build { inherit system overlays; nixpkgs = nixpkgs-darwin; };

in nixpkgs' // { inherit pkgs-alt; }
