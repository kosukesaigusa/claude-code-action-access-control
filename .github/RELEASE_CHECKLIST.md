# Release Checklist

## Pre-Release Checklist

### Code Quality

- [ ] All tests pass (`test.yml` workflow)
- [ ] Action syntax is valid
- [ ] Permission check script works correctly
- [ ] Update check script works correctly

### Documentation

- [ ] README.md is complete and accurate
- [ ] CHANGELOG.md is updated with new changes
- [ ] Examples in `.github/workflows/example.yml` work
- [ ] All references use correct action name

### Security

- [ ] No hardcoded secrets or tokens
- [ ] Permission logic is secure (no wildcards)
- [ ] Input validation is proper

### Marketplace Readiness

- [ ] `action.yml` has correct name and description
- [ ] Branding icon and color are set
- [ ] License file exists (MIT)
- [ ] Repository is public

## Release Process

### 1. Version Decision

- Patch (x.x.1): Bug fixes only
- Minor (x.1.0): New features, backward compatible
- Major (2.0.0): Breaking changes

### 2. Tag Creation

```bash
git tag -a v0.0.1 -m "Initial beta release v0.0.1"
git push origin v0.0.1
```

### 3. GitHub Marketplace

1. Go to repository Settings
2. Navigate to Actions → General
3. Click "Publish this Action to GitHub Marketplace"
4. Fill in category (Utilities or Security)
5. Submit for review

### 4. Post-Release

- [ ] Verify release appears on GitHub
- [ ] Check Marketplace listing
- [ ] Test installation from Marketplace
- [ ] Update any external documentation
