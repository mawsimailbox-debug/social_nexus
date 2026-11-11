FROM golang:1.27.3-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY cmd ./cmd
COPY internal ./internal
RUN CGO_ENABLED=0 go build -trimpath -o /api ./cmd/api && CGO_ENABLED=0 go build -trimpath -o /migrate ./cmd/migrate
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /api /api
COPY --from=build /migrate /migrate
COPY migrations /migrations
WORKDIR /
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/api"]
