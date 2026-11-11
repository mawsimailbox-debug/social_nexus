#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../backend-go"
test -s go.mod
for tool in go golangci-lint goimports staticcheck; do command -v "$tool" >/dev/null; done
files=$(gofmt -l .)
[[ -z "$files" ]] || { printf 'Unformatted Go files:\n%s\n' "$files"; exit 1; }
[[ -z "$(goimports -l .)" ]] || exit 1
golangci-lint run ./...
staticcheck ./...
go vet ./...
mkdir -p ../qa/reports
go test ./... -race -covermode=atomic -coverprofile=../qa/reports/go-coverage.out
go tool cover -func=../qa/reports/go-coverage.out > ../qa/reports/go-coverage.txt
python3 ../ci/check-coverage.py ../qa/reports/go-coverage.out
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -o ../qa/reports/api-linux-amd64 ./cmd/api
