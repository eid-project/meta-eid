IMAGENAME ?= eid-image
CNAME ?= eid
DOCKERRUN ?=docker run -w /home/eid --cap-add SYS_ADMIN -u 1000 --rm --name $(CNAME)

start: .build
	$(DOCKERRUN) -it $(IMAGENAME)

.build:
	docker build --build-arg http_proxy=$(http_proxy) \
	             --build-arg https_proxy=$(https_proxy) \
	             --build-arg no_proxy=$(no_proxy) \
	             -t $(IMAGENAME) . && touch .build

clean:
	rm -f .build

.PHONY: start clean
