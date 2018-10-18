IMAGENAME ?= eid-image
CNAME ?= eid

start: .build
	docker run -w /home/eid --cap-add SYS_ADMIN -itu 1000 --name $(CNAME) $(IMAGENAME)
	docker rm $(CNAME)

.build:
	docker build --build-arg http_proxy=$(http_proxy) \
	             --build-arg https_proxy=$(https_proxy) \
	             --build-arg no_proxy=$(no_proxy) \
	             -t $(IMAGENAME) . && touch .build

clean:
	rm -f .build

.PHONY: start clean
