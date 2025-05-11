build-deb:
	love-release -D

build-windows:
	love-release -W

build-macos:
	love-release -M

build:
	make build-deb
	make build-windows
	make build-macos