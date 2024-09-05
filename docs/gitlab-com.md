# Running on gitlab.com

The gitlab.com runners are already configured
correctly and can run the image without any issue.


```yaml
stages:
  - testing

ddev-initialize:
  stage: testing
  image: ghcr.io/ochorocho/ddev-gitlab-ci:v1.23
  variables:
    # Remove "umask 0000" usage, so DDEV has permissions on the cloned repository
    # see https://docs.gitlab.com/runner/configuration/feature-flags.html#available-feature-flags
    FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR: 1
  services:
    - name: docker:dind
  when: always
  script:
    # Fix for: Error response from daemon: invalid mount config for type "bind": bind source path does not exist: /builds/*/*'
    - ddev config global --no-bind-mounts=true
    - ddev --version
    # ... do things
```
