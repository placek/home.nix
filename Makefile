apply:
	@echo "Applying home-manager configuration..."
	NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/release-23.11 -- --impure switch -b backup
