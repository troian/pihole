REGISTRY           ?= ghcr.io
TAG_VERSION        ?= $(shell git describe --tags --abbrev=0)

ifeq ($(REGISTRY),)
	IMAGE_NAME         := troian/pihole:$(TAG_VERSION)
	IMAGE_NAME_LATEST  := troian/pihole:latest
else
	IMAGE_NAME         := $(REGISTRY)/troian/pihole:$(TAG_VERSION)
	IMAGE_NAME_LATEST  := $(REGISTRY)/troian/pihole:latest
endif

DOCKER_BUILD=docker build

# Makefile does not support / in stem (aka %).
# use hyphens for arch specifications and substitute it later in place
SUBIMAGES = amd64 \
 arm64-v8 \
 arm-v7

HYPHEN := -
SLASH  := /
EMPTY  :=

.PHONY: pihole-%
pihole-%:
	$(DOCKER_BUILD) --platform=linux/$(subst $(HYPHEN),$(SLASH),$*) \
		--build-arg PIHOLE_DOCKER_TAG=$(TAG_VERSION) \
		-t $(IMAGE_NAME)-$(subst $(HYPHEN),$(EMPTY),$*) \
		-t $(IMAGE_NAME_LATEST)-$(subst $(HYPHEN),$(EMPTY),$*) \
		-f Dockerfile .

.PHONY: pihole
pihole: $(patsubst %, pihole-%,$(SUBIMAGES))

.PHONY: docker-push-%
docker-push-%:
	docker push $(IMAGE_NAME)-$(subst $(HYPHEN),$(EMPTY),$*)
	docker push $(IMAGE_NAME_LATEST)-$(subst $(HYPHEN),$(EMPTY),$*)

.PHONY: docker-push
docker-push: $(patsubst %, docker-push-%,$(SUBIMAGES))

.PHONY: manifest-create
manifest-create:
	@echo "creating manifest $(IMAGE_NAME)"
	docker maninfest rm $(IMAGE_NAME) 2> /dev/null || true
	docker maninfest rm $(IMAGE_NAME_LATEST) 2> /dev/null || true
	docker manifest create $(IMAGE_NAME) $(foreach arch,$(SUBIMAGES), --amend $(IMAGE_NAME)-$(subst $(HYPHEN),$(EMPTY),$(arch)))
	docker manifest create $(IMAGE_NAME_LATEST) $(foreach arch,$(SUBIMAGES), --amend $(IMAGE_NAME_LATEST)-$(subst $(HYPHEN),$(EMPTY),$(arch)))

.PHONY: manifest-push
manifest-push:
	@echo "pushing manifest $(IMAGE_NAME)"
	docker manifest push $(IMAGE_NAME)
	docker manifest push $(IMAGE_NAME_LATEST)

.PHONY: gen-changelog
gen-changelog:
	@echo "generating changelog to changelog"
	./scripts/genchangelog.sh $(shell git describe --tags --abbrev=0) changelog.md
