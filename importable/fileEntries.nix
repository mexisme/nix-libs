let
  inherit (builtins) attrNames attrValues elemAt filter foldl' isAttrs isList listToAttrs length map match pathExists readDir replaceStrings throw toString trace;

  isImportable args: let
    # If args is not a set, then we'll assume it's a
    args' = let
      args-check = { entry, dirPath ? ./ }: { inherit entry, dirPath; };
    in if isAttrs args then args-check args else { entry = args };

    isNixFile = with args'; match ".*\\.nix" entry != null;
    isNixDir = with args'; pathExists (dirPath + "/" + entry + "/default.nix");
  in
     isNixFile || isNixDir;

  # extract the file-name to prefix + fully-qualified path
  dirEntryToAttr = dirPath: dirEntry: let
    entryNameSplit = match "(.+)\\.nix|(.+)" dirEntry;
    entryPrefixes = filter (n: entryNameSplit != null) entryNameSplit;
    entryPrefix = if (length entryPrefixes) == 0
                  then throw "Could not match an entry prefix against '${dirEntry}'."
                  else elemAt entryPrefixes 0;
    # name, value pair, where "name" has ".nix" removed
    fullPath = dirPath + "/${dirEntry}";
  in
    { name = entryPrefix; value = fullPath; };

  dirEntriesToAttrs = ;
in {
  inherit isImportable dirEntryToAttr dirEntriesToAttrs;
}
