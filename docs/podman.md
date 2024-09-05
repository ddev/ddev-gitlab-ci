# Docker in Podman

The following example describes how to configure the GitLab Runner
to use DDEV within the docker executor using Podman (DockerInPodman).

* Configure the [Runner to use Podman](https://docs.gitlab.com/runner/executors/docker.html#use-podman-to-run-docker-commands). More details in the [forum](https://forum.gitlab.com/t/gitlab-runner-setup-with-podman/87893/2)

## GitLab Runner config.toml

`/etc/gitlab-runner/config.toml`:

```toml
[[runners]]
  name = "Podman Runner"
  executor = "docker"
  # ...
  [runners.docker]
    # ...
    tls_verify = false
    services_privileged = true
    allowed_privileged_services = ["docker:dind"]
    # Replace 1000 with the users id, run `id -u` to get the id
    host = "unix:///run/user/1000/podman/podman.sock"
```

## GitLab CI Job for DDEV  

`.gitlab-ci.yml`:

```yaml
stages:
  - testing

ddev-initialize-podman:
  stage: testing
  image: ghcr.io/ochorocho/ddev-gitlab-ci:v1.23
  variables:
    # Remove "umask 0000" usage, so DDEV has permissions on the cloned repository
    # see https://docs.gitlab.com/runner/configuration/feature-flags.html#available-feature-flags
    FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR: 1
    # Disable Docker SSL connection
    DOCKER_TLS_CERTDIR: ""
    # Fix: "Error response from daemon: bad parameter: link is not supported"
    FF_NETWORK_PER_BUILD: 1
  services:
    - name: docker:dind
  when: always
  script:
    - ddev start
    # ... do things
```
