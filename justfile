# anolis-provider-template-cpp dev commands. CI runs build, test and fmt-check.
# Needs VCPKG_ROOT pointing at a vcpkg checkout, and python3 for the harness.

harness_wheel := "https://github.com/anolishq/anolis-protocol/releases/download/v1.10.0/anolis_protocol-1.10.0-py3-none-any.whl"
binary := "build/release/anolis-provider-template-cpp"

# List available recipes
default:
    @just --list

# Configure and build the provider (vcpkg builds its dependencies on the first run)
build:
    cmake --preset release
    cmake --build --preset release --parallel

# Run the anolis-protocol conformance harness against the built provider
test: build
    test -x .harness/bin/anolis-adpp-conformance || (python3 -m venv .harness && .harness/bin/pip install -q "anolis-protocol[conformance] @ {{harness_wheel}}")
    python3 scripts/conformance.py {{binary}} .harness/bin/anolis-adpp-conformance

# Format the C++ sources (clang-format 18)
fmt:
    clang-format -i src/*.cpp

# Check formatting without changing files
fmt-check:
    clang-format --dry-run --Werror src/*.cpp

# Rename the provider after "Use this template": just rename <kind> (e.g. bme280-lab)
rename kind:
    scripts/rename.sh {{kind}}
