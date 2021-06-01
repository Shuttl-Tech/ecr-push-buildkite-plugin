#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

@test "Creates and push a docker image from Dockerfile" {
  export BUILDKITE_PLUGIN_ECR_PUSH_REPOSITORY="app/repo"
  export BUILDKITE_COMMIT="abcdefghijklmn"

  stub curl \
        '-s http://169.254.169.254/latest/meta-data/placement/availability-zone : echo az eu-central-1a'

  stub aws \
        "sts get-caller-identity --output text : echo '123456789012	arn:aws:iam::123456789012/user/role	ABCDEFGHIJKLMNOPQRSTU'"  \
        "ecr describe-repositories --region eu-central-1 --repository-names app/repo --registry-id 123456789012 --output text --query 'repositories[0].repositoryUri' : echo docker.repo.test/app/repo"

  stub docker \
        'build --file Dockerfile --tag docker.repo.test/app/repo . : echo "image built"'              \
        'tag docker.repo.test/app/repo docker.repo.test/app/repo:abcdefghijklmn : echo "first tag"'   \
        'push docker.repo.test/app/repo:abcdefghijklmn : echo "first tag pushed"'                     \
        'tag docker.repo.test/app/repo docker.repo.test/app/repo:abcdefgh : echo "second tag"'        \
        'push docker.repo.test/app/repo:abcdefgh : echo "second tag pushed"'

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "--- Building Docker image"
  assert_output --partial "Dockerfile: Dockerfile"
  assert_output --partial "Build context: ."
  assert_output --partial "--- Pushing Tag: 'abcdefghijklmn'"
  assert_output --partial "--- Pushing Tag: 'abcdefgh'"
  assert_output --partial "image built"
  assert_output --partial "first tag"
  assert_output --partial "first tag pushed"
  assert_output --partial "second tag"
  assert_output --partial "second tag pushed"
}

@test "Creates and push a public image from Dockerfile to public repository" {
  export BUILDKITE_PLUGIN_ECR_PUSH_REPOSITORY="app/repo"
  export BUILDKITE_PLUGIN_ECR_PUSH_PUBLIC_ORG_NAME="shuttl"
  export BUILDKITE_COMMIT="abcdefghijklmn"

  stub curl \
        '-s http://169.254.169.254/latest/meta-data/placement/availability-zone : echo az eu-central-1a'

  stub aws \
        "ecr-public get-login-password --region us-east-1" \
        "sts get-caller-identity --output text : echo '123456789012	arn:aws:iam::123456789012/user/role	ABCDEFGHIJKLMNOPQRSTU'"  \
        "ecr-public describe-repositories --region us-east-1 --repository-names app/repo --registry-id 123456789012 --output text --query 'repositories[0].repositoryUri' : echo docker.repo.test/app/repo"

  stub docker \
        'login --username AWS --password-stdin public.ecr.aws/shuttl : echo "logged in to public repo"'   \
        'build --file Dockerfile --tag docker.repo.test/app/repo . : echo "image built"'                  \
        'tag docker.repo.test/app/repo docker.repo.test/app/repo:abcdefghijklmn : echo "first tag"'       \
        'push docker.repo.test/app/repo:abcdefghijklmn : echo "first tag pushed"'                         \
        'tag docker.repo.test/app/repo docker.repo.test/app/repo:abcdefgh : echo "second tag"'            \
        'push docker.repo.test/app/repo:abcdefgh : echo "second tag pushed"'

  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "logged in to public repo"
  assert_output --partial "--- Building Docker image"
  assert_output --partial "Dockerfile: Dockerfile"
  assert_output --partial "Build context: ."
  assert_output --partial "--- Pushing Tag: 'abcdefghijklmn'"
  assert_output --partial "--- Pushing Tag: 'abcdefgh'"
  assert_output --partial "image built"
  assert_output --partial "first tag"
  assert_output --partial "first tag pushed"
  assert_output --partial "second tag"
  assert_output --partial "second tag pushed"
}
