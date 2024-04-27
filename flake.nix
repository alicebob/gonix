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

        cache = pkgs.stdenv.mkDerivation {
          name = "gocache";
          src = pkgs.lib.sourceByRegex ./. [
            "^go.(mod|sum)$"
            "vendor"
            "vendor/.*"
          ];
          configurePhase = "true";
          buildPhase = ''
export GOFLAGS=-trimpath
export GOPROXY=off
export GOSUMDB=off
export GOCACHE=$out/cache
mkdir -p $out/cache;

${pkgs.go}/bin/go build -v `cat vendor/modules.txt |grep -v '#'|grep -v sys/windows|grep -v tpmutil/tbs|grep -v internal`
mkdir -p $out/nix-support
cat > $out/nix-support/setup-hook <<EOF
	echo in setup-hoop, cp $out/cache to $TMPDIR/go-cache
	cp --reflink=auto -r $out/cache $TMPDIR/go-cache
	chmod -R +w $TMPDIR/go-cache
EOF
		  '';
          installPhase = "true";
		  fixupPhase = "true";
          #vendorHash = null; # uses ./vendor/
          #checkPhase = "true"; # no unittests please
          #postInstall = ''
          #mkdir -p $out/run/
          #'';
        };

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
          #postInstall = ''
          #mkdir -p $out/run/
          #'';
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
