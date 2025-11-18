# GitHub Actions Improvement - Kanban Board

## 🔴 Critical (Must Fix for CI to Work)

- [ ] Set `PATH_HELPER_DOCKER_INSTANCE=true` environment variable in workflow
- [ ] Fix install script path from `/tmp/install.sh` to `docker/install.sh`
- [ ] Fix `spec/shell_spec.sh:187` - change `return $PASS` to `exit $PASS`
- [ ] Update `actions/checkout` from v2 to v4
- [ ] Update `actions/upload-artifact` from v2 to v4

## 📋 To Do - Short Term

### Workflow Modernization
- [ ] Update Ruby version matrix (remove 2.3.7, add 3.0, 3.1, 3.2)
- [ ] Add `workflow_dispatch` trigger for manual runs
- [ ] Add concurrency control to prevent duplicate runs
- [ ] Add explicit permissions declaration
- [ ] Add job/step timeout configurations

### Performance & Caching
- [ ] Add APT package caching to speed up builds
- [ ] Optimize test setup to reduce execution time
- [ ] Add build matrix fail-fast configuration

### Test Reporting
- [ ] Upload test results on both success and failure
- [ ] Add test result summary to workflow output
- [ ] Add step to display test failures in readable format
- [ ] Configure artifact retention period

### Documentation
- [ ] Document new workflow structure in README
- [ ] Add contributing guide for CI/CD changes
- [ ] Document how to run tests locally vs CI

## 📋 To Do - Medium Term

### Language-Agnostic Infrastructure
- [ ] Create `.github/actions/setup-test-env/` composite action
- [ ] Create `.github/actions/run-shell-tests/` composite action
- [ ] Extract common test setup logic from workflow
- [ ] Create reusable test execution wrapper

### Workflow Restructuring
- [ ] Create `test-ruby.yml` workflow (language-specific)
- [ ] Create `ci.yml` main workflow (orchestrator)
- [ ] Add workflow for testing Docker builds
- [ ] Add workflow for release automation

### Multi-Language Support Preparation
- [ ] Design workflow structure for Crystal implementation
- [ ] Design workflow structure for Go implementation
- [ ] Create template for adding new language implementations
- [ ] Document multi-language testing strategy

### Enhanced Testing
- [ ] Add shell integration tests (bash, zsh, sh)
- [ ] Add tests for different OS environments (Ubuntu, Alpine, macOS)
- [ ] Add edge case tests for path handling
- [ ] Add validation tests for setup command

## 📋 To Do - Long Term

### Future Language Implementations
- [ ] Implement `test-crystal.yml` workflow (when Crystal implementation exists)
- [ ] Implement `test-go.yml` workflow (when Go implementation exists)
- [ ] Add cross-language compatibility tests
- [ ] Add performance comparison between implementations

### Advanced Features
- [ ] Add test result reporting with PR comments
- [ ] Add code coverage tracking (per language)
- [ ] Add performance benchmarking workflow
- [ ] Add automated changelog generation
- [ ] Add automated release creation on version tags

### Quality & Security
- [ ] Add dependency vulnerability scanning
- [ ] Add SAST (static analysis security testing)
- [ ] Add workflow security best practices audit
- [ ] Add automated dependency updates (Dependabot)

### Developer Experience
- [ ] Add local GitHub Actions testing setup (act)
- [ ] Add pre-commit hooks for common issues
- [ ] Add developer setup script
- [ ] Create troubleshooting guide for CI failures

## 🚧 In Progress

<!-- Move tasks here when actively working on them -->

## ✅ Done

<!-- Move completed tasks here -->

---

## Notes

### Workflow Execution Order
1. Critical fixes must be implemented first (workflow won't work otherwise)
2. Short-term improvements can be done incrementally
3. Medium-term restructuring should be done as a cohesive unit
4. Long-term features can be added as needed

### Testing Strategy
- Test all changes on a feature branch first
- Validate workflow with `act` locally before pushing
- Monitor first few runs carefully for issues
- Keep rollback plan ready for critical workflows

### Multi-Language Support
The goal is to support multiple language implementations (Ruby, Crystal, Go) while maintaining a single, language-agnostic test suite (shell_spec.sh). The workflow structure should:
- Support language-specific setup and dependencies
- Run the same shell-based tests for all implementations
- Allow parallel execution of tests across languages
- Provide unified reporting and status checks

### Dependencies
- `alpine-pbuilder` package required for tests
- Shell test framework in `spec/shell_spec.sh`
- Test fixtures in `spec/fixtures/`
- Docker setup in `docker/` directory

### Resources
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Composite Actions Guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Act - Local Testing](https://github.com/nektos/act)
