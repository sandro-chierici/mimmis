.PHONY: run build tidy lint test

## run: start the API server (loads .env if present)
run:
	@[ -f .env ] && export $$(grep -v '^#' .env | xargs) ; go run ./cmd/api/...

## build: compile the API binary to ./bin/api
build:
	go build -o bin/api ./cmd/api/...

## tidy: tidy and vendor dependencies
tidy:
	go mod tidy

## lint: run golangci-lint (requires golangci-lint installed)
lint:
	golangci-lint run ./...

## test: run all tests with race detector
test:
	go test -race ./...
