apply:
	@echo "Applying home-manager configuration..."
	nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/release-23.11 -- --impure switch -b backup

configure:
	@echo "Configuring NixOS..."
	sudo cp --backup --interactive --link machines/omega/configuration.nix /etc/nixos/configuration.nix
	sudo nixos-rebuild switch
