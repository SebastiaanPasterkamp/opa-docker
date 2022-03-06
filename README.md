# Open Policy Agent Docker image

This project builds a binary-only docker image for the
[Open Policy Agent](https://www.openpolicyagent.org/)
command line tool.

## Usage:

The docker image can be used as a drop-in command line
tool:

```bash
docker run --rm -i cromrots/opa fmt < policy.rego
```

Or as a CI image:

```yaml
  ...

  - name: rego:test
    image: cromrots/opa
    commands:
      - opa test -v internal/policy/rego/
      - opa test -v internal/policy/testdata/

  ...
```

## Security

The binary is build using the official golang image,
by calling `go install github.com/open-policy-agent/opa`.
The final base image is `FROM scratch`, and runs as a
non-root user/group `1000:2000` in `/etc/passwd`.