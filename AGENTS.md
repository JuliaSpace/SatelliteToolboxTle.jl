# AGENTS.md

SatelliteToolboxTle.jl — tools to parse, create, and fetch TLEs (two-line elements). Part of the JuliaSpace ecosystem.

## Package Structure

- Requires Julia 1.10 or newer (`[compat]` in `Project.toml`).
- Entrypoint: `src/SatelliteToolboxTle.jl`. Include order: `types.jl`, then `conversion.jl`, `checksum.jl`, `parse.jl`, `read.jl`, `show.jl`, then the fetcher API (`fetcher/api.jl`, `fetcher/celestrak.jl`), and finally `precompile.jl` (PrecompileTools workload). New code can only reference symbols defined in files included before it.
- The TLE fetcher API is documented in `src/fetcher/API.md`; `fetcher/celestrak.jl` implements it for CelesTrak.
- Runtime deps: Crayons, Dates, Downloads, PrecompileTools, Printf, URIs. No package extensions and no `deps/build.jl` (`Pkg.build()` is a no-op).
- Test-only deps are declared via `[extras]` + `[targets]` in `Project.toml` (Test, Logging). There is no `test/Project.toml`.
- Tests do not mirror `src/` file-for-file. `test/runtests.jl` includes: `checksum.jl`, `parse_tles_from_strings.jl`, `parse_tles_from_files.jl`, `macros.jl`, `conversions.jl`, `printing.jl`, `errors.jl`, `tle_fetchers.jl`. Each is wrapped in `@testset "Name" verbose = true begin ... end`; new test files should follow that convention. Sample TLE fixtures live in `test/*.tle`.
- `test/runtests.jl` installs `Logging.NullLogger()` globally to keep output clean — expect no log output during tests.

## Commands

- Instantiate: `julia --project=. -e 'using Pkg; Pkg.instantiate()'`
- Full test suite: `julia --project=. -e 'using Pkg; Pkg.test()'`
- Focused test file, from the `test/` directory: `julia --project=.. -e 'using Test, Dates, SatelliteToolboxTle; include("<file>.jl")'` — run with `test/` as the working directory because fixture paths (e.g. `samples.tle`) are cwd-relative, matching how `Pkg.test()` runs them.
- Format: `julia -e 'using JuliaFormatter; format(".")'` — no `--project=.`; JuliaFormatter is not a project dependency, so run it from an environment where it is installed.
- Build docs: `julia --project=docs docs/make.jl` — first local run needs `julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'`.
- Use generous timeouts: the first `Pkg.instantiate()`/`Pkg.test()` triggers precompilation and can run for minutes while printing little. Slow startup is precompilation, not a hang.
- There is no test-name selector; run the full suite or include a single test file as above.
- `test/tle_fetchers.jl` downloads TLEs from CelesTrak — it needs network access and can fail offline.

## Code Style

- Formatting follows `.JuliaFormatter.toml`: Blue style with alignment options enabled (`align_assignment`, `align_pair_arrow`, `align_struct_field`, etc.) and `whitespace_in_kwargs = true`. That file is the source of truth.
- CI does **not** enforce formatting — keep the style manually when editing.
- Source files use boxed section headers (`####...# Title #####...`) — match them when adding sections.

## CI

- `ci.yml`: tests on Julia 1.10 (oldest supported) and latest stable 1.x, on ubuntu-latest (x64), macos-latest (arm64), and windows-latest (x64); builds the package, runs tests, and uploads coverage to Codecov.
- `ci-nightly.yml`: same OS/arch matrix on Julia nightly.
- `docs.yml` builds/deploys documentation; `CompatHelper.yml` and `TagBot.yml` handle dependency compat and releases.
- `Pkg.test()` alone reproduces the CI test step locally.

## Not Configured

- No linter, no Aqua/JET checks, no pre-commit hooks, no format-check CI job — do not invent them.
- No `Manifest.toml` is committed; dependencies resolve fresh from `[compat]`.
