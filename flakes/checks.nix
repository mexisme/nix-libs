{ system,
}:

{
  # We can't access `isDarwin` when attrs like `currentSystem` are impure:
  isDarwin = with builtins; match ".*-darwin" system != null;
}
