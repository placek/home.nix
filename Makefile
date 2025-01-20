expiration ?= 30 days

hm-flake := home-manager/release-24.05
hm := nix --extra-experimental-features nix-command --extra-experimental-features flakes run $(hm-flake) -- --impure
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
	sudo nix-channel --update
	$(rebuild) --upgrade

expire:
	$(hm) expire-generations "-$(expiration)"

gens:
	$(hm) generations

gc:
	nix-collect-garbage --delete-older-than "$(shell echo "$(expiration)" | sed 's/ days/d/')"
	nix-store --optimise

news:
	$(hm) news

all: upgrade apply expire gc

.PHONY: apply switch upgrade expire gens gc all
