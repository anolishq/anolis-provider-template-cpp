# AGENTS.md: anolis-provider-template-cpp

The template every C++ provider starts from. Changes here reach every provider
made from it afterwards, so keep it small: one synthetic device, the SDK, and
the build and release a provider needs.

## Build / test

- `just build` (CMake preset `release`, vcpkg from `VCPKG_ROOT`), then `just test`, the conformance harness through
  `scripts/conformance.py`. CI builds with the `ci` preset (warnings as errors) on x86_64 and arm64.
- The required CI status check is the **`ok`** job; never merge red.
- `scripts/conformance.py` requires the harness to pass with no skips beyond `EXPECTED_SKIPS`: the two deadline tests,
  until the C++ SDK supports deadlines (anolis-provider-sdk#71). Remove them from the list when it does.
- clang-format 18.1.8 (`.clang-format` is the SDK's). CI checks it.

## Rules

- **Self-contained.** CI and release use only public actions, the local `.github/actions/vcpkg`, and public anolishq
  releases: no reusable anolishq workflows, actions or secrets. A provider made from the template must build and
  release in any account.
- **`scripts/rename.sh` must keep working.** The `rename` CI job renames the template, builds it and runs the
  harness; a new file that names the template has to be covered by the script.
- **The heater matches the SDK's reference provider** (`examples/reference/` in anolis-provider-sdk) and the Python
  template. Keep the three the same device.
- The SDK is pinned by release tarball and SHA256 in `CMakeLists.txt`.
- The template is never tagged or released itself.
- An outside instance generated from this template proves the path from another account; if the build or release
  path changes, repeat that proof (see the README).
