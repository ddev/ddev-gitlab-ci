# Docker in Docker

The following example describes how to configure the GitLab Runner
to use DDEV within the docker executor (DockerInDocker).

* GitLab [Docker in Docker docs](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker)
* [Enable SSL](https://about.gitlab.com/blog/2019/07/31/docker-in-docker-with-docker-19-dot-03/#configure-tls) connection
* Potential [security risk described](https://docs.gitlab.com/runner/security/#usage-of-docker-executor)

## GitLab Runner config.toml

`/etc/gitlab-runner/config.toml`:

```toml
[[runners]]
  name = "Docker Runner"
  executor = "docker"
  # ...
  [runners.docker]
    # ...
    tls_verify = false
    services_privileged = true
    allowed_privileged_services = ["docker:dind"]
```

## GitLab CI Job for DDEV  

`.gitlab-ci.yml`:

```yaml
stages:
  - testing

ddev-initialize-docker:
  stage: testing
  image: ghcr.io/ddev/ddev-gitlab-ci:v1.23
  variables:
    # Remove "umask 0000" usage, so DDEV has permissions on the cloned repository
    # see https://docs.gitlab.com/runner/configuration/feature-flags.html#available-feature-flags
    FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR: 1
    # Disable Docker SSL connection
    DOCKER_TLS_CERTDIR: ""
    # Fix "fatal: unable to access '<REPO>': Could not resolve host: <HOST>"
    FF_NETWORK_PER_BUILD: 0
  services:
    - name: docker:dind
  when: always
  script:
    - ddev start
    # ... do things
```
