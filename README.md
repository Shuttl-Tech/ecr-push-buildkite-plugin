# ECR Push Buildkite Plugin

*Note:* This plugin is a fork of [seek-oss/docker-ecr-publish-buildkite-plugin].

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to build, tag,
and push Docker images to Amazon ECR.

## Example

The following pipeline builds the default `./Dockerfile` and pushes it to a
pre-existing ECR repository `my-repo`:

```yml
steps:
  - plugins:
      - Shuttl-Tech/ecr-push#v1.0.0:
          repository: my-repo
```

An alternate Dockerfile may be specified:

```yml
steps:
  - plugins:
      - Shuttl-Tech/ecr-push#v1.0.0:
          dockerfile: path/to/final.Dockerfile
          repository: my-repo
```

[Build-time variables](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg)
are supported, either with an explicit value, or without one to propagate an environment variable from the pipeline step:

## Configuration

- `context` (optional, string)

  The Docker build context. Valid values are as per the [API](https://docs.docker.com/engine/reference/commandline/build/#extended-description)

  Default: `.`

- `cache_from_tag` (optional, string)

  Images tag in target repository for Docker to use as cache sources, e.g. a base or dependency image.

- `dockerfile` (optional, string)

  Local path to a custom Dockerfile.

  Default: `Dockerfile`

- `repository` (required, string)

  Name of the ECR repository.

- `region` (optional, string)

  Region the ECR registry is in, defaults to `$AWS_DEFAULT_REGION` and then to the AWS region of build agent if not set.

- `tags` (optional, array|string)

  Tags to push on all builds.

  Default: `$BUILDKITE_COMMIT` and first 8 characters of the commit hash.

- `public_org_name` (optional, string)

  Name of the public ECR organization if the image is to be pushed to a public ECR repository.

## License

MIT (see [LICENSE](LICENSE))
