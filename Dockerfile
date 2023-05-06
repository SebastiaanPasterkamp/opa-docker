FROM --platform=${BUILDPLATFORM} drone/git:1.2.1 as clone

WORKDIR /tmp

ARG GIT_TAG=v0.52.0

RUN git clone \
    --depth 1 \
    --branch $GIT_TAG \
    https://github.com/open-policy-agent/opa.git

FROM --platform=${BUILDPLATFORM} golang:1.20 as build

COPY --from=clone /tmp/opa ./opa

ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN cd opa && \
    go build \
        -o opa \
        -ldflags "-s -w" \
        main.go

FROM --platform=${BUILDPLATFORM} alpine:3.17.0 AS nonroot

ENV USER=opa
ENV UID=1000
ENV GID=2000

RUN addgroup \
        -g "$GID" \
        -S \
        $USER \
    && adduser \
        -S \
        -D \
        -g "" \
        -G "$USER" \
        -H \
        -u "$UID" \
        "$USER"

FROM alpine:3.17.0

ENV UID=1000
ENV GID=2000

COPY --from=nonroot /etc/passwd /etc/passwd
COPY --chown=$UID:$GID --from=build /go/opa/opa /

USER $UID

WORKDIR /data

SHELL [ "/opa" ]

ENTRYPOINT [ "/opa" ]

CMD [ "--help" ]
