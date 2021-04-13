# `test_suites`

This project contains BYOND environments used for testing the Donk Transpiler and API.

It also provides Starlark functions (`dm2pb`, `donk_library`) for generating
a transpiled codebase in order to provide it directly as a Bazel dependency
of another target.

To provide the Bazel targets expected by these rules
(`@spacemandmm//src/dm2pb:dm2pb`, `@donk_transpiler//bazel:transpiler`)
please see the [`third_party_buildfiles`][tpb] repository.

[tpb]: [https://github.com/warriorstar-orion/third_party_buildfiles.

## License

Donk Project is Copyright 2021 (c) Warriorstar Orion and released under the
MIT license.
