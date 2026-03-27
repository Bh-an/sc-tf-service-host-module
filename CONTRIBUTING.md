# Contributing

## Commits

[Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): short description
```

| Rule | Detail |
|------|--------|
| Types | `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci` |
| Scopes | `terraform`, `packer`, `infra`, `docs` |
| Subject | Imperative mood, under 72 chars, no trailing period |
| Granularity | One logical change per commit |

## Branches

| Branch | Purpose |
|--------|---------|
| `main` | Tagged releases |
| `dev` | Integration and release prep |
| `ci-cd` | Workflow and automation changes only |
| `docs/*` | Short-lived documentation updates |

## Pending Branch Protection Plan

> [!NOTE]
> This is the intended GitHub policy, but it is **not enforced yet**.

- `main` should require pull requests
- direct pushes to `main` should be blocked
- required checks should pass before merge
- `dev` should at least block force-push and deletion

Until GitHub protection is enabled, contributors should treat PR-based merges into `main` as mandatory.

## Before You Commit

```bash
packer validate packer/docker-host.pkr.hcl
cd terraform && terraform init -backend=false && terraform validate
```

## Releases

Releases are cut from `main` by pushing a semver tag:

```bash
git tag v0.4.0
git push origin v0.4.0
```

`.github/workflows/release.yml` validates the repo and creates a GitHub Release.
