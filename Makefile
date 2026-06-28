default: bootstrap

bootstrap:
	./setup/bootstrap.zsh

sync:
	./setup/sync.zsh

macos:
	./setup/macos.zsh

.PHONY: bootstrap sync macos
