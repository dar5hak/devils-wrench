build-deb:
	love-release -D

build-windows:
	love-release -W

build-macos:
	love-release -M

clean:
	rm -rf build

build:
	make clean
	make build-deb
	make build-windows
	make build-macos