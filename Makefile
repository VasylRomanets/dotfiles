default: bootstrap

bootstrap:
	./setup/bootstrap.zsh

sync:
	./setup/sync.zsh

prune-symlinks:
	./setup/prune-symlinks.zsh

macos:
	./setup/macos.zsh

.PHONY: bootstrap sync prune-symlinks macos
