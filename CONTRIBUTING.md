# Contributing

## Commit Standard

Use Conventional Commits:

```text
type(scope): short description
```

- Allowed types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`
- Common scopes: `terraform`, `packer`, `infra`, `docs`
- Keep the subject imperative, under 72 characters, and without a trailing period
- Do not add AI attribution lines

## Branching

- `main` is the stable branch
- `dev` is the shared integration and release-prep branch
- `ci-cd` is reserved for workflow, release, and automation-only changes

## Releases

- Terraform releases are cut from `main`
- push a semver tag like `v0.3.0` on a commit already reachable from `main`
- `.github/workflows/release.yml` validates the repo and creates the GitHub Release

## Before You Commit

Run the relevant validators:

```bash
packer validate packer/docker-host.pkr.hcl
cd terraform && terraform validate
```
