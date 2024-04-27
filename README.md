Experiment to keep the Go build cache around for Go projects which use Nix and vendor their modules.

Status: seems to work.

Usage: copy gocache.nix into your own project, and use it as an input:

```
   ...
   cache = pkgs.callPackage ./gocache.nix { };
   yourgomodule = pkgs.buildGoModule {
      name = "yourgomodule";
      buildInputs = [ cache ];
      ...
   }
   ...
```

I upload everything to my local attic cache.


Based on https://github.com/numtide/build-go-cache .
