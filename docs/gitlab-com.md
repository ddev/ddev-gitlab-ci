# Running on gitlab.com

The gitlab.com runners are already configured
correctly and can run the image without any issue.

`.gitlab-ci.yml`:

```yaml
stages:
  - testing

ddev-initialize:
  stage: testing
  image: ghcr.io/ddev/ddev-gitlab-ci:stable
  variables:
    # Remove "umask 0000" usage, so DDEV has permissions on the cloned repository
    # see https://docs.gitlab.com/runner/configuration/feature-flags.html#available-feature-flags
    FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR: 1
  services:
    - name: docker:dind
  when: always
  script:
    - ddev --version
    # ... do things
```
