# pre-commit Docker packaging

This is just enough Docker to run [pre-commit](https://pre-commit.com) as a CI
stage.

### IMPORTANT!!! Enable insecure registries in Docker

Add following content to `/etc/docker/daemon.json`:

``` json
{
  "insecure-registries": ["172.16.0.12:5000"]
}
```

And restart docker with:

    sudo systemctl restart docker

## Usage

### Docker

```bash
$ docker run -it --rm --volume "$(pwd)":/code 172.16.0.12:5000/pre-commit:latest
```

### Git commit hook

``` bash
cat <<\EOF >.git/hooks/pre-commit
docker run --rm -v "$(pwd)":/code 172.16.0.12:5000/pre-commit:latest
EOF

chmod 755 .git/hooks/pre-commit
```


### GitLab CI

#### Recommended: shared template on LC GitLab

To avoid needing to update the configuration in the future, you can simply
include the template from this repository to run pre-commit during your
project's `validate` stage:

```yaml
include:
    - project: mirror/pre-commit-docker
      file: templates/pre-commit.yml
```

If you want to run during a different stage, you can override the default:

```yaml
include:
    - project: mirror/pre-commit-docker
      file: templates/pre-commit.yml

precommit:
    stage: test
```

#### Alternate (previous usage)

If you want more control over exactly how the job is run you can configure the
job directly:

```yaml
precommit:
    image:
        name: 172.16.0.12:5000/pre-commit:latest
        entrypoint: [""]
    script:
        - exec /usr/local/bin/run-pre-commit
```

### GitHub Actions

```yaml
name: CI

on:
    push:
        branches:
            - master

jobs:
    pre-commit:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v1
            - name: Fetch pre-commit Docker image
              env:
                  PRE_COMMIT_ACCESS_TOKEN: ${{ secrets.PRE_COMMIT_ACCESS_TOKEN }}
              run: |
                  docker login docker.pkg.github.com -u acdha -p ${PRE_COMMIT_ACCESS_TOKEN}
                  docker pull docker.pkg.github.com/acdha/pre-commit-docker/pre-commit-docker:master
            - name: Run pre-commit
              run: |
                  docker run --volume "$PWD":/code docker.pkg.github.com/acdha/pre-commit-docker/pre-commit-docker:master
```
