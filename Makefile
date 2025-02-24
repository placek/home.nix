expiration ?= 30 days
version ?= 24.05

nixos-channel := https://nixos.org/channels/nixos-$(version)
home-manager-channel := https://github.com/nix-community/home-manager/archive/release-$(version).tar.gz

HOME-MANAGER := home-manager
NIXOS := sudo nixos-rebuild

nixos-config := /etc/nixos/configuration.nix


.PHONY: all
all: upgrade apply expire gc

.PHONY: $(nixos-config)
$(nixos-config):
	sudo cp --backup --interactive --link machines/$$(hostname)/configuration.nix $@

.PHONY: switch
switch: $(nixos-config) displaylink
	$(NIXOS) switch

.PHONY: apply
apply: update
	$(HOME-MANAGER) switch

.PHONY: update
update: $(nixos-config)
	sudo sudo nix-channel --remove nixos
	sudo sudo nix-channel --remove home-manager
	sudo nix-channel --add $(nixos-channel) nixos
	sudo nix-channel --add $(home-manager-channel) home-manager
	sudo nix-channel --update

.PHONY: upgrade
upgrade: update
	$(NIXOS) switch --upgrade

.PHONY: install
install: update
	nix-shell '<home-manager>' -A install

.PHONY: expire
expire:
	$(HOME-MANAGER) expire-generations "-$(expiration)"
	nix-collect-garbage --delete-older-than "$(shell echo "$(expiration)" | sed 's/ days/d/')"

.PHONY: gens
gens:
	$(HOME-MANAGER) generations
	$(NIXOS) list-generations

.PHONY: gc
gc:
	nix-store --optimise

.PHONY: news
news:
	$(HOME-MANAGER) news

displaylink: files/displaylink-600.zip
	nix-prefetch-url file://$(shell pwd)/$<
