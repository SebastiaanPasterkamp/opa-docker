FROM openpolicyagent/opa:0.50.1-static as opa

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
COPY --chown=$UID:$GID --from=opa /opa /

USER $UID

WORKDIR /data

SHELL [ "/opa" ]

ENTRYPOINT [ "/opa" ]

CMD [ "--help" ]
