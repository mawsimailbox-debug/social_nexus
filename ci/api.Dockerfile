ARG GO_IMAGE
ARG RUNTIME_IMAGE
FROM ${GO_IMAGE} AS build
WORKDIR /src
COPY backend-go/ ./
RUN go mod download && CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags='-s -w' -o /out/api ./cmd/api && CGO_ENABLED=0 GOOS=linux go build -trimpath -o /out/migrate ./cmd/migrate
FROM ${RUNTIME_IMAGE}
RUN apk add --no-cache ca-certificates && addgroup -g 10001 nexus && adduser -D -H -u 10001 -G nexus nexus
WORKDIR /app
COPY --from=build /out/api /app/api
COPY --from=build /out/migrate /app/migrate
COPY backend-go/migrations/ /app/migrations/
COPY ci/api-entrypoint.sh /usr/local/bin/nexus-entrypoint
USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["/bin/sh", "/usr/local/bin/nexus-entrypoint"]
