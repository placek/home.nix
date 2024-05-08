expiration ?= 30 days

hm-flake := home-manager/release-23.11
hm := NIXPKGS_ALLOW_INSECURE=1 nix --extra-experimental-features nix-command --extra-experimental-features flakes run $(hm-flake) -- --impure
rebuild := sudo nixos-rebuild switch
link := sudo cp --backup --interactive --link
nixos-config := /etc/nixos/configuration.nix

apply:
	$(hm) switch -b backup

.PHONY: $(nixos-config)
$(nixos-config):
	$(link) machines/$$(hostname)/configuration.nix $@

switch: $(nixos-config)
	$(rebuild)

upgrade: $(nixos-config)
	$(rebuild) --upgrade

expire:
	$(hm) expire-generations "-$(expiration)"

gens:
	$(hm) generations

gc:
	nix-collect-garbage --delete-older-than "$(shell echo "$(expiration)" | sed 's/ days/d/')"
	nix-store --optimise
