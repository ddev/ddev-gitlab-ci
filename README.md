# DDEV Docker in Docker (dind)

This image is most likely to be used within the GitLab Runner.
As of now it only tested it on gitlab.com

# Workflow - Image build

Build the image

```bash
./build.sh -v <version, at least major.minor> -p
``` 

Available options:
 * v - DDEV version e.g. 'v1.23.1' 
 * l - Load the image (--load)
 * p - Push the image (--push)

## Version to tags

| Command               | Tags to be created             |
|-----------------------|--------------------------------|
| ./build.sh -v v1.22   | v1.22, v1.22.x (latest bugfix) |
| ./build.sh -v v1.22.5 | v1.22.5                        |
| ./build.sh -v v1.23   | v1.23, v1.23.x (latest bugfix) |
| ...                   | ...                            |

