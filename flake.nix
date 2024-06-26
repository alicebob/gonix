{
  description = "compile test for Go";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        cache = pkgs.callPackage ./gocache.nix { };

        everything = pkgs.buildGoModule {
          name = "gonix";
          buildInputs = [ cache ];
          src = pkgs.lib.sourceByRegex ./. [
            "^go.(mod|sum)$"
            "vendor"
            "vendor/.*"
            "echo-svc"
            "echo-svc/.*"
          ];
          vendorHash = null; # uses ./vendor/
          checkPhase = "true"; # no unittests please
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "echo";
          src = everything;
          configurePhase = "true";
          buildPhase = "true";
          installPhase = ''
            mkdir -p $out/;
            cp bin/echo-svc $out/;
          '';
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            #(sox.override { enableLame = true; })
            #opusTools
            #ffmpeg-headless
            #python310Packages.weasyprint
            # gotools
            # go-tools
          ];
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    ));
}
