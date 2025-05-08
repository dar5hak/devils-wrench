build-deb:
	love-release -D

build-windows:
	love-release -W

build:
	make build-deb
	make build-windows