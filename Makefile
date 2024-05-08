apply:
	@echo "Applying home-manager configuration..."
	nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/release-23.11 -- --impure switch -b backup

configure:
	@echo "Configuring NixOS..."
	sudo cp --backup --interactive --link machines/$$(hostname)/configuration.nix /etc/nixos/configuration.nix
	sudo nixos-rebuild switch

upgrade:
	@echo "Configuring and upgrading NixOS..."
	sudo cp --backup --interactive --link machines/$$(hostname)/configuration.nix /etc/nixos/configuration.nix
	sudo nixos-rebuild switch --upgrade

expire:
	@echo "Expiring home-manager generations older than a month..."
	nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/release-23.11 -- --impure expire-generations "-30 days"

gens:
	@echo "Listing home-manager generations..."
	nix --extra-experimental-features nix-command --extra-experimental-features flakes run home-manager/release-23.11 -- --impure generations
