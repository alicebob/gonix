{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "gocache";
  buildInputs = [ pkgs.gnugrep ];
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
       cp --reflink=auto -r $out/cache $TMPDIR/go-cache
       chmod -R +w $TMPDIR/go-cache
    EOF
  '';
  installPhase = "true";
  fixupPhase = "true";
}
