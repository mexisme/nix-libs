let
  isImportable = n: path: with builtins;
    match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"));

in {
  # Find a list of Nix importables from the given Path, ordered lexicographically
  #   path: path to search for Nix importables
  findImportablesInPath = path: with builtins; let
    # find all the entries in a dir
    dirEntries = readDir path;
    # extract just the path-names
    dirNames = attrNames dirEntries;
    importableEntries = filter (n: (isImportable n path)) dirNames;
  in map (n: (path + "/${n}")) importableEntries;

  # Given a Package File-name, or List of Package File-names, prepend each with the given Path
  #   pkgsOrPkgs: a single or list of package file-names
  #   path: path to prepend before each package file-name
  extendPackageFilenamesWithPath = pkgOrPkgs: path: with builtins; let
    pkgs = if (isList pkgOrPkgs) then pkgOrPkgs else [pkgOrPkgs];
  in builtins.map (n: (path + "/${n}")) pkgs;

  # Given an iterator function for returning FQ Package (paths) and a list of Paths, import each
  # Package using the given Attrs
  #   fn: function that will return a list of packages, based of the given list of paths
  #   paths: a list of paths to iterate
  #   attrs: an attr set to pass with each package import
  #
  # e.g.
  #   importPkgsFrom (extendPackageFilenamesWithPath pkgs) paths attrs;
  #   importPkgsFrom findImportablesInPath paths attrs;
  importPkgsFrom = fn: pathOrPaths: attrs: with builtins; let
    paths = if (isList pathOrPaths) then pathOrPaths else [pathOrPaths];
    pkgs = foldl' (prev: path: (prev ++ (fn path))) [] paths;
  in map (n: import n attrs) pkgs;
}
