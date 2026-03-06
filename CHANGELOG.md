# external-monitoring-integration Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security
- [#3] Update kubectl to fix CVE-2025-68121

## [v1.0.0] - 2026-02-09

### Added

- Namespaces for external monitoring
- NetworkPolicies for external monitoring
- Secrets to access Prometheus for external monitoring
- [#1] Automate Prometheus restart after creating secrets