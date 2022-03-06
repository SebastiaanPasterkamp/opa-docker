FROM golang:1.17 as build

ENV CGO_ENABLED=0
ENV GOBIN=/

ARG GIT_TAG=v0.37.2

RUN go install github.com/open-policy-agent/opa@$GIT_TAG

FROM alpine AS nonroot

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

FROM scratch

WORKDIR /

ENV UID=1000
ENV GID=2000

COPY --from=nonroot /etc/passwd /etc/passwd
COPY --chown=$UID:$GID --from=build /opa /

USER $USER

ENTRYPOINT [ "/opa" ]

CMD [ "--help" ]