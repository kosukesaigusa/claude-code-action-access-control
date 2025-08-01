# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2024-08-01

### Added

- Initial beta release of Claude Code Action Access Control
- User-based access control with `allowed_users` parameter
- Team-based access control with `allowed_teams` parameter  
- Organization-wide access control with `allow_org_members` parameter
- Full compatibility with all official Claude Code Action parameters
- Comprehensive test suite
- Automatic upstream sync checking

### Security

- Removed wildcard pattern support to prevent unauthorized access
- Implemented exact-match only user validation
- Added comprehensive permission checking logic

[Unreleased]: https://github.com/kosukesaigusa/claude-code-action-access-control/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/kosukesaigusa/claude-code-action-access-control/releases/tag/v0.0.1
