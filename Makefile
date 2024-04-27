.PHONY: build
build:
	nix build

.PHONY: vendor
vendor:
	go mod tidy
	go mod vendor

.PHONY: fmt
fmt:
	nix fmt flake.nix
