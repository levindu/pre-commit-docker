all: build # docker-push

HTTP_PROXY=http://172.16.0.14:8123
NO_PROXY=localhost,127.0.0.0/8,172.16.0.0/16,192.168.0.0/16
APT_PROXY=http://172.16.0.14:3142

build:
	docker build \
        --build-arg http_proxy=$(HTTP_PROXY) \
        --build-arg https_proxy=$(HTTP_PROXY) \
        --build-arg no_proxy=$(NO_PROXY) \
        --build-arg apt_proxy=$(APT_PROXY) \
		-t pre-commit:latest .

docker-push:
	docker tag pre-commit:latest 172.16.0.12/pre-commit:latest
	docker push 172.16.0.12/pre-commit:latest

test: build
	docker run -it --rm -v $(shell pwd):/code pre-commit:latest
