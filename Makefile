.PHONY: build
build:
	nix build -L

.PHONY: vendor
vendor:
	go mod tidy
	go mod vendor

.PHONY: fmt
fmt:
	nix fmt flake.nix gocache.nix
