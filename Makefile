expiration ?= 30 days

hm-flake := home-manager/release-24.05
hm := nix run $(hm-flake) --
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

displaylink: files/displaylink-600.zip
	nix-prefetch-url file://$(shell pwd)/$<

all: upgrade displaylink apply expire gc

.PHONY: apply switch upgrade expire displaylink gens gc all
