.PHONY: proto docker-shell

PROTO_DIR := proto
PROTOC_GEN_GO_OUT := pb
ROOT_PROTO_FILES := $(wildcard *.proto)
PROTO_FILES_FROM_DIR := $(shell if [ -d $(PROTO_DIR) ]; then find $(PROTO_DIR) -name '*.proto'; fi)
STRIPPED_PROTO_FILES := $(patsubst $(PROTO_DIR)/%,%,$(PROTO_FILES_FROM_DIR))
PROTO_FILES := $(strip $(ROOT_PROTO_FILES) $(STRIPPED_PROTO_FILES))
PROTO_INCLUDE_PATHS := --proto_path=. $(if $(PROTO_FILES_FROM_DIR),--proto_path=$(PROTO_DIR))

proto: _require_proto_files
	docker compose run --rm --build proto protoc $(PROTO_INCLUDE_PATHS) --go_out=$(PROTOC_GEN_GO_OUT) --go_opt=paths=source_relative --go-grpc_out=$(PROTOC_GEN_GO_OUT) --go-grpc_opt=paths=source_relative $(PROTO_FILES)

_require_proto_files:
	@if [ -z "$(strip $(PROTO_FILES))" ]; then \
		echo "No .proto files found in $(PROTO_DIR) or current directory"; \
		exit 1; \
	fi

docker-shell:
	docker compose run --rm proto bash
