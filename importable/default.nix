let
  inherit (builtins) attrNames attrValues elemAt filter foldl' isList listToAttrs length map match pathExists readDir replaceStrings throw toString trace;

  isImportable = n: path:
    match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"));

  # extract the file-name to prefix + fully-qualified path
  dirEntryToAttr = path: dir-entry: let
    entryNameSplit = match "(.+)\\.nix|(.+)" dir-entry;
    entryPrefixes = filter (n: trace "name ${toString n}" entryNameSplit != null) entryNameSplit;
    entryPrefix = if (length entryPrefixes) == 0
                  then throw "Could not match an entry prefix against '${dir-entry}'."
                  else elemAt 0 entryPrefixes;
    # name, value pair, where "name" has ".nix" removed
    fullPath = path + "/${dir-entry}";
  in
    { name = entryPrefix; value = fullPath; };

  dirEntriesToAttrs = path: dirEntries: let
    attrList = map (n: dirEntryToAttr path n) dirEntries;
  in
    listToAttrs attrList;

  # Find a list of Nix importables from the given Path, ordered lexicographically
  #   path: path to search for Nix importables
  findImportableEntriesInPath = path: let
    # find all the entries in a dir
    dirEntries = readDir path;
    # extract just the path-names
    dirNames = attrNames dirEntries;
    # filter for the importable entries
    importableEntries = filter (n: (isImportable n path)) dirNames;
  in
    dirEntriesToAttrs path importableEntries;

  findImportablesInPath = path:
    attrValues (findImportableEntriesInPath path);

  # Given a Package File-name, or List of Package File-names, prepend each with the given Path
  #   pkgsOrPkgs: a single or list of package file-names
  #   path: path to prepend before each package file-name
  #
  extendPackagePaths' = pkgOrPkgs: path: let
    pkgs = if (isList pkgOrPkgs) then pkgOrPkgs else [pkgOrPkgs];
    entries = dirEntriesToAttrs path pkgs;
  in {
    extendPackageEntriesWithPath = entries;
    extendPackageFilenamesWithPath = attrValues entries;
  };
  inherit (extendPackagePaths')
    extendPackageEntriesWithPath extendPackageFilenamesWithPath;

  # Given an iterator function for returning FQ Package (paths) and a list of Paths, import each
  # Package using the given Attrs
  #   fn: function that will return a list of packages, based of the given list of paths
  #   paths: a list of paths to iterate
  #   attrs: an attr set to pass with each package import
  #
  # e.g.
  #   importPkgsFrom (extendPackageFilenamesWithPath pkgs) paths attrs;
  #   importPkgsFrom findImportablesInPath paths attrs;
  importPkgsFrom = fn: pathOrPaths: attrs: let
    paths = if (isList pathOrPaths) then pathOrPaths else [pathOrPaths];
    pkgs = foldl' (prev: path: (prev ++ (fn path))) [] paths;
  in
    map (n: import n attrs) pkgs;

in {
  inherit
    findImportableEntriesInPath findImportablesInPath
    extendPackageEntriesWithPath extendPackageFilenamesWithPath
    importPkgsFrom;
}
