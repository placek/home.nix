expiration ?= 30 days
version ?= 25.11

nixos-channel := https://nixos.org/channels/nixos-$(version)
home-manager-channel := https://github.com/nix-community/home-manager/archive/release-$(version).tar.gz

HOME-MANAGER := home-manager
NIXOS := sudo nixos-rebuild

nixos-config := /etc/nixos/configuration.nix


.PHONY: apply
apply: update
	$(HOME-MANAGER) switch

.PHONY: all
all: upgrade apply gc

.PHONY: $(nixos-config)
$(nixos-config):
	sudo cp --backup --interactive --link machines/$$(hostname)/configuration.nix $@

.PHONY: switch
switch: $(nixos-config) displaylink
	$(NIXOS) switch

.PHONY: update
update:
	sudo sudo nix-channel --remove nixos
	sudo sudo nix-channel --remove home-manager
	sudo nix-channel --add $(nixos-channel) nixos
	sudo nix-channel --add $(home-manager-channel) home-manager
	sudo nix-channel --update

.PHONY: upgrade
upgrade: update $(nixos-config)
	$(NIXOS) switch --upgrade

.PHONY: install
install: update
	nix-shell '<home-manager>' -A install

.PHONY: repair-store
repair-store:
	sudo nix-store --verify --check-contents --repair

.PHONY: gc
gc: repair-store
	$(HOME-MANAGER) expire-generations "-$(expiration)"
	nix-collect-garbage --delete-older-than "$(shell echo "$(expiration)" | sed 's/ days/d/')"
	nix-store --optimise

.PHONY: gens
gens:
	$(HOME-MANAGER) generations
	$(NIXOS) list-generations

.PHONY: news
news:
	$(HOME-MANAGER) news

displaylink:
	nix-prefetch-url --name displaylink-610.zip https://www.synaptics.com/sites/default/files/exe_files/2024-10/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.1-EXE.zip
