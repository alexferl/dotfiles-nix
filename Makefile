.PHONY: help rebuild update check gc

.DEFAULT_GOAL: help
help:
	@echo "make rebuild"
	@echo "	Rebuild the system configuration"
	@echo "make update"
	@echo "	Update flake inputs"
	@echo "make check"
	@echo "	Check configuration for errors"
	@echo "make gc"
	@echo "	Run garbage collection"

rebuild:
	sudo darwin-rebuild switch --flake .#mac-10

update:
	nix flake update

check:
	sudo darwin-rebuild check --flake .#mac-10

gc:
	nix-collect-garbage -d
	nix store optimise
