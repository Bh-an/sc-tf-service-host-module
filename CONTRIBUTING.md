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

## Before You Commit

Run the relevant validators:

```bash
packer validate packer/docker-host.pkr.hcl
cd terraform && terraform validate
```
