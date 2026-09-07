# AGENTS.md

SatelliteToolboxTle.jl — tools to parse, create, write, and fetch TLEs (two-line elements). Part of the JuliaSpace ecosystem.

## Package Structure

- Requires Julia 1.10 or newer (`[compat]` in `Project.toml`).
- Entrypoint: `src/SatelliteToolboxTle.jl`. Include order: `types.jl`, then `checksum.jl`, `conversion.jl`, `parse.jl`, `read.jl`, `show.jl`, `write.jl`, then the fetcher API (`fetcher/api.jl`, `fetcher/celestrak.jl`), and finally `precompile.jl` (PrecompileTools workload). New code can only reference symbols defined in files included before it, except inside function bodies.
- `types.jl` defines `TLE`, whose inner constructor validates that every field fits the fixed-width TLE format (so writing never fails), the keyword constructor (which also accepts `epoch::DateTime`), the `epoch` property via `Base.getproperty`, and the exceptions `TleParseError` and `TleFetchError`.
- `parse.jl` throws `TleParseError` for malformed input; the multi-TLE reader (`_parse_tles`) catches it, emits a warning, and skips the TLE. Numeric fields with an implied decimal point are parsed as integers and scaled by the exact powers of ten in `_POWERS_OF_TEN`, so the values are correctly rounded and the hot path does not allocate. `ArgumentError` is reserved for bad keyword arguments.
- `write.jl` writes the lines digit by digit (no Printf): every TLE field is an integer or a fixed-point number scaled to an integer. `write_tle(String, tle)` returns the text; do not add a `Base.convert(::Type{String}, ::TLE)` method, since it invalidates the `convert(String, ::Any)` call sites of Base and other packages.
- Satellite catalog numbers above 99999 use the Alpha-5 scheme (`_ALPHA5_LETTERS`), and the two-digit epoch year pivots at `_EPOCH_YEAR_PIVOT` (57), matching the SGP4 reference implementation.
- `show.jl` prints the TLE with the tree helpers of **SatelliteToolboxBase.jl** v2.1 (`print_tree`, `print_tree_body`, `PrintedField`, `PrintedSection`), imported by name in the module entrypoint, and overloads `SatelliteToolboxBase.print_tree_body`. The colors come from the `StyledStrings` faces registered by SatelliteToolboxBase, so tests must not match exact escape sequences.
- The TLE fetcher API is documented in `src/fetcher/API.md`; `fetcher/celestrak.jl` implements it for CelesTrak using the `Downloads` stdlib and throws `TleFetchError` on request failures.
- Runtime deps: Dates, Downloads, PrecompileTools, SatelliteToolboxBase, URIs. No package extensions and no `deps/build.jl` (`Pkg.build()` is a no-op).
- Test-only deps are declared via `[extras]` + `[targets]` in `Project.toml` (Test, Logging). There is no `test/Project.toml`.
- Tests do not mirror `src/` file-for-file. `test/runtests.jl` includes: `checksum.jl`, `parse_tles_from_strings.jl`, `parse_tles_from_files.jl`, `macros.jl`, `alpha5.jl`, `conversions.jl`, `printing.jl`, `errors.jl`, `tle_fetchers.jl`. Each is wrapped in `@testset "Name" verbose = true begin ... end`; new test files should follow that convention. Sample TLE fixtures live in `test/*.tle`.
- `test/runtests.jl` installs `Logging.NullLogger()` globally to keep output clean — expect no log output during tests.

## Commands

- Instantiate: `julia --project=. -e 'using Pkg; Pkg.instantiate()'`
- Full test suite: `julia --project=. -e 'using Pkg; Pkg.test()'`
- Focused test file, from the `test/` directory: `julia --project=.. -e 'using Test, Dates, SatelliteToolboxTle; include("<file>.jl")'` — run with `test/` as the working directory because fixture paths (e.g. `samples.tle`) are cwd-relative, matching how `Pkg.test()` runs them.
- Format: `julia -e 'using JuliaFormatter; format(".")'` — no `--project=.`; JuliaFormatter is not a project dependency, so run it from an environment where it is installed. Recent JuliaFormatter releases undo the manual alignment, so review the diff and keep only the intended changes.
- Build docs: `julia --project=docs docs/make.jl` — first local run needs `julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'`. The manual pages contain executable `@repl` blocks, so the build fails if the examples break.
- Use generous timeouts: the first `Pkg.instantiate()`/`Pkg.test()` triggers precompilation and can run for minutes while printing little. Slow startup is precompilation, not a hang.
- There is no test-name selector; run the full suite or include a single test file as above.
- `test/tle_fetchers.jl` downloads TLEs from CelesTrak — it needs network access and can fail offline.

## Code Style

- Formatting follows `.JuliaFormatter.toml`: Blue style with alignment options enabled (`align_assignment`, `align_pair_arrow`, `align_struct_field`, etc.) and `whitespace_in_kwargs = true`. That file is the source of truth.
- CI does **not** enforce formatting — keep the style manually when editing.
- Source files use boxed section headers (`####...# Title #####...`) — match them when adding sections. Every function, including private ones, has a docstring.

## CI

- `ci.yml`: tests on Julia 1.10 (oldest supported) and latest stable 1.x, on ubuntu-latest (x64), macos-latest (arm64), and windows-latest (x64); builds the package, runs tests, and uploads coverage to Codecov.
- `ci-nightly.yml`: same OS/arch matrix on Julia nightly.
- `docs.yml` builds/deploys documentation; `CompatHelper.yml` and `TagBot.yml` handle dependency compat and releases.
- `Pkg.test()` alone reproduces the CI test step locally.

## Not Configured

- No linter, no Aqua/JET checks, no pre-commit hooks, no format-check CI job — do not invent them.
- No `Manifest.toml` is committed; dependencies resolve fresh from `[compat]`.
