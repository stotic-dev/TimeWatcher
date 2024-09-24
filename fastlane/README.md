fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

do test

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload App for TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Upload App for release

### ios upload_beta

```sh
[bundle exec] fastlane ios upload_beta
```

Upload ipa for TestFlight

### ios upload_release

```sh
[bundle exec] fastlane ios upload_release
```

Upload ipa for release

### ios match_force_appstore

```sh
[bundle exec] fastlane ios match_force_appstore
```

create appstore cert and profiles

### ios fetch_appstore_profiles

```sh
[bundle exec] fastlane ios fetch_appstore_profiles
```

fetch appstore profiles and cert

### ios delete_appstore_profiles

```sh
[bundle exec] fastlane ios delete_appstore_profiles
```

delete appstore profiles and cert

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
