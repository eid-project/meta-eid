IMAGENAME ?= eid-image
CNAME ?= eid
DOCKERRUN ?= docker run \
		--env http_proxy=$(http_proxy) \
		--env https_proxy=$(https_proxy) \
		--env no_proxy=$(no_proxy) \
		--workdir /home/eid \
		--cap-add SYS_ADMIN \
		--security-opt seccomp:unconfined \
		--security-opt apparmor:unconfined \
		-u 1000 \
		--rm \
		--name $(CNAME)

RUNTEST ?= $(DOCKERRUN) $(IMAGENAME) source ./poky/meta-eid/setup.sh;

start: .build
	$(DOCKERRUN) -it $(IMAGENAME)

.build:
	-docker stop -t0 $(CNAME)
	docker build --build-arg http_proxy=$(http_proxy) \
	             --build-arg https_proxy=$(https_proxy) \
	             --build-arg no_proxy=$(no_proxy) \
	             -t $(IMAGENAME) . && touch .build

test: clean .build
	bash ./test.sh

clean:
	rm -f .build

.PHONY: start clean
