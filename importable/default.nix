let
  inherit (builtins) attrNames attrValues elem filter foldl' isList listToAttrs map match pathExists readDir replaceStrings;

  isImportable = n: path:
    match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"));

  # extract the file-name to prefix + fully-qualified path
  dirEntryToAttr = path: n: let
    entryNameSplit = match "(.+)\\.nix|(.+)" n;
    entryNameNixFile = elem entryNameSplit 0;
    entryNameNixDir = elem entryNameSplit 1;
    entryPrefix =
      if entryNameNixFile != null
      then entryNameNixFile
      else entryNameNixDir;
    # name, value pair, where "name" has ".nix" removed
    fullPath = path + "/${n}";
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
  extendPackageFilenamesWithPath = pkgOrPkgs: path: let
    pkgs = if (isList pkgOrPkgs) then pkgOrPkgs else [pkgOrPkgs];
  in
    attrValues (dirEntriesToAttrs path pkgs);

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

in { inherit findImportableEntriesInPath findImportablesInPath extendPackageFilenamesWithPath importPkgsFrom; }
