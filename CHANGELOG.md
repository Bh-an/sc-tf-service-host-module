# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.4] - 2026-03-27

### Fixed
- Tightened default Nginx routing to expose only `/api/v1` and `/health`
- Added a direct Nginx health endpoint for bootstrap diagnostics
- Verified both Nginx health and app health after restart

## [0.3.3] - 2026-03-27

### Fixed
- Hardened baked host runtime defaults and bootstrap script resilience

## [0.3.2] - 2026-03-25

### Added
- SSM-backed AMI contract (`ami_ssm_parameter_name` variable) for pinned AMI selection
- AMI publication script (`scripts/publish-ami-parameter.sh`)

## [0.3.0] - 2026-03-15

### Changed
- Renamed reusable module from `ec2-service` to `service-host`
- Automated tagged releases via GitHub Actions (`release.yml`)

## [0.2.0] - 2026-03-10

### Changed
- Extracted reusable Terraform modules from monolithic root stack
- Separated network and service-host concerns into independent modules

## [0.1.1] - 2026-03-05

### Fixed
- Aligned GHCR defaults and repo naming in variable defaults

## [0.1.0] - 2026-03-01

### Added
- Initial Packer AMI template (Amazon Linux 2023 + Docker + Nginx)
- Root Terraform stack with EC2, KMS, EBS, IAM, security group, Nginx, Docker bootstrap
- Full Go web server application (later extracted to service repo)
