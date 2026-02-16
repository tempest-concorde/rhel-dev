# CHANGELOG

## v0.5.0 (2026-02-16)

### Feature

* feat: add extra binaries and cosign to bootc image (#15)

Add OpenShift install (4.18, 4.19, 4.20), oc, kubectl, oc-mirror,
gomplate, and cosign binaries to the container image. Fix direnv
install path and add direnv shell hook. Update gomplate to v4.3.3
across the board.

Co-authored-by: Claude Opus 4.6 (1M context) &lt;noreply@anthropic.com&gt; ([`e3ca342`](https://github.com/tempest-concorde/rhel-dev/commit/e3ca3427853fdd1d1445842e3e38c54879b5a0b9))

### Fix

* fix(deps): Bump actions/checkout from 4 to 6 (#12)

Bumps [actions/checkout](https://github.com/actions/checkout) from 4 to 6.
- [Release notes](https://github.com/actions/checkout/releases)
- [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
- [Commits](https://github.com/actions/checkout/compare/v4...v6)

---
updated-dependencies:
- dependency-name: actions/checkout
  dependency-version: &#39;6&#39;
  dependency-type: direct:production
  update-type: version-update:semver-major
...

Signed-off-by: dependabot[bot] &lt;support@github.com&gt;
Co-authored-by: dependabot[bot] &lt;49699333+dependabot[bot]@users.noreply.github.com&gt;
Co-authored-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`65d4da2`](https://github.com/tempest-concorde/rhel-dev/commit/65d4da24a0d1cb6477a902e35ab19ea882da2a50))

* fix: add commit-message config to dependabot docker ecosystem (#16)

Co-authored-by: Claude Opus 4.6 (1M context) &lt;noreply@anthropic.com&gt; ([`c27b238`](https://github.com/tempest-concorde/rhel-dev/commit/c27b238b54f8942bd6ded29d1d18ebeae06bdadb))

## v0.4.1 (2026-01-07)

### Fix

* fix: add security details (#8)

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`e903a03`](https://github.com/tempest-concorde/rhel-dev/commit/e903a038102a04341c4515e52725f264d3faf250))

## v0.4.0 (2026-01-07)

### Feature

* feat: allow multiarchitecture builds (#7)

* feat: allow multiarchitecture builds

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

* fix: do not push images in CI

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

---------

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`e2d2998`](https://github.com/tempest-concorde/rhel-dev/commit/e2d2998661ee988c841482cc26aab61f3dee1109))

## v0.3.0 (2025-08-07)

### Feature

* feat: add java and tailscale (#6)

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`b130a11`](https://github.com/tempest-concorde/rhel-dev/commit/b130a11321a4f2646c36e84cffaebd85e4b1c2c2))

## v0.2.4 (2025-08-07)

### Fix

* fix: add guest agents (#5)

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`4020d8f`](https://github.com/tempest-concorde/rhel-dev/commit/4020d8fb77c6808bae72fa35bf1ec4de3c60e047))

## v0.2.3 (2025-08-06)

### Fix

* fix: password_hash

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`cf47600`](https://github.com/tempest-concorde/rhel-dev/commit/cf476000b23a205101c59064d74e708ea40b16d6))

## v0.2.2 (2025-08-06)

### Chore

* chore: simplify

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`eb33f28`](https://github.com/tempest-concorde/rhel-dev/commit/eb33f28375d662d107ec9457b181b285f8311144))

* chore: externalize user config

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`7f15805`](https://github.com/tempest-concorde/rhel-dev/commit/7f15805bceabbcf38127ee907713e69599c0ea63))

### Fix

* fix: update with sdvs example

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`49e0e34`](https://github.com/tempest-concorde/rhel-dev/commit/49e0e347e8b94ec7b2b73f18137d1c5dccedbc8d))

## v0.2.1 (2025-08-05)

### Chore

* chore: update toml

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`2dc8507`](https://github.com/tempest-concorde/rhel-dev/commit/2dc8507d4f12f9de5a9e4f9bb8e521b68702f432))

* chore: update config toml

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`4155241`](https://github.com/tempest-concorde/rhel-dev/commit/4155241f673150e90430daf2ddbecabdcd20a3f8))

* chore: update config toml

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`4476f81`](https://github.com/tempest-concorde/rhel-dev/commit/4476f8185e1bd81749f7823c21dd002d220d45da))

* chore: wrapping toml

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`0056689`](https://github.com/tempest-concorde/rhel-dev/commit/0056689fd1e880c296d7eda9da3914f2857442b6))

* chore: remove root check

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`431ca78`](https://github.com/tempest-concorde/rhel-dev/commit/431ca7862ebdeea161cdc7c52ff686abfe9af64d))

* chore: correct make syntax

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`4aad606`](https://github.com/tempest-concorde/rhel-dev/commit/4aad606523f8411621e9728d437142e6fbc71ea1))

* chore: add qcow make file

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`58fccac`](https://github.com/tempest-concorde/rhel-dev/commit/58fccacc39f0c97c9c46c0724132599042a18f5e))

### Fix

* fix: simplify

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`a829b0e`](https://github.com/tempest-concorde/rhel-dev/commit/a829b0eb646b411735b49f1ca252c205f9d4c950))

## v0.2.0 (2025-08-04)

### Feature

* feat: fix token workflow (#4)

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`cfda23f`](https://github.com/tempest-concorde/rhel-dev/commit/cfda23f09b9f3b01c9762a8cb7b2803bc966df84))

## v0.1.0 (2025-08-04)

### Feature

* feat: update process to ensure updates (#2)

* feat: update process to ensure updates

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

* fix: manually install epel

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

* fix: manually install direnv

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

* fix: manually install direnv

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

---------

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`3a6f468`](https://github.com/tempest-concorde/rhel-dev/commit/3a6f468579b3c74cee2f5b876c6a3926ec59d53f))

* feat: initial build (#1)


Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`47dee46`](https://github.com/tempest-concorde/rhel-dev/commit/47dee465b958d85ed5e86a7e9603322c88b7c117))

### Fix

* fix: stuff (#3)

* fix: stuff

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

* fix: add direnv correctly

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt;

---------

Signed-off-by: Chris Butler &lt;chris.butler@redhat.com&gt; ([`0fb9d33`](https://github.com/tempest-concorde/rhel-dev/commit/0fb9d33f14c9b45958869341d46061c5944b5b06))

* fix: dependabot.yml

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`7f03823`](https://github.com/tempest-concorde/rhel-dev/commit/7f038239ada6dc1b9221e3d92b7abfc4178b477e))

### Unknown

* Initial commit ([`117528d`](https://github.com/tempest-concorde/rhel-dev/commit/117528de645d131757eb053c7403fe40949c9d81))
