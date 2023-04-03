{ importable,
}:

{ name,
  pkgs,
  pkg-groups,
  packageFiles,
  extraOutputsToInstall ? [ "man" ],
}:

let
  inherit (importable) importPkgsFrom extendPackageFilenamesWithPath;

  paths = importPkgsFrom (extendPackageFilenamesWithPath packageFiles) pkg-groups pkgs;
  # paths = with importable; importPkgsFrom (extendPackageFilenamesWithPath pkgs) ../../groups nix-all;
  # paths = with importable; importPkgsFrom findImportablesInPath ./pkgs/all nix-all;
in
pkgs.buildEnv {
  # pathsToLink ignoreCollisions postBuild;

  inherit name paths extraOutputsToInstall;

  # paths = [
  # ]
  # ++ lib.optionals (!stdenv.isDarwin) [
  # ];

  # ++ lib.optional (???) PACKAGE;
  # ++ lib.optionals (???) [PACKAGE ...];
  # ??? = (stdenv.isDarwin) or (!stdenv.isDarwin) or (lib.versionAtLeast lib.version "20")
}
