<p align="center">
  <img src="./docs/src/assets/logo.png" width="150" title="SatelliteToolboxTransformations.jl"><br>
  <small><i>This package is part of the <a href="https://github.com/JuliaSpace/SatelliteToolbox.jl">SatelliteToolbox.jl</a> ecosystem.</i></small>
</p>

# SatelliteToolboxTle.jl

[![CI](https://img.shields.io/github/actions/workflow/status/JuliaSpace/SatelliteToolboxTle.jl/ci.yml?style=flat-square&logo=githubactions&logoColor=white&labelColor=475569&label=CI)](https://github.com/JuliaSpace/SatelliteToolboxTle.jl/actions/workflows/ci.yml)
[![Codecov](https://img.shields.io/codecov/c/github/JuliaSpace/SatelliteToolboxTle.jl?token=SPIKBIN3ES&style=flat-square&logo=codecov&logoColor=white&labelColor=475569)](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTle.jl)
[![docs-stable](https://img.shields.io/badge/docs-stable-16A34A?style=flat-square&logo=gitbook&logoColor=white&labelColor=475569)][docs-stable-url]
[![docs-dev](https://img.shields.io/badge/docs-dev-D97706?style=flat-square&logo=gitbook&logoColor=white&labelColor=475569)][docs-dev-url]
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495D1?style=flat-square&logo=julia&logoColor=white&labelColor=475569)](https://github.com/invenia/BlueStyle)
[![License](https://img.shields.io/github/license/JuliaSpace/SatelliteToolboxTle.jl?style=flat-square&logo=readme&logoColor=white&labelColor=475569&color=0284C7)](https://github.com/JuliaSpace/SatelliteToolboxTle.jl/blob/main/LICENSE)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.11245282-DB2777?style=flat-square&logo=doi&logoColor=white&labelColor=475569)](https://zenodo.org/doi/10.5281/zenodo.11245282)

This package allows creating, fetching, and parsing TLEs (two-line elements).

## Two-line elements

The TLE, or two-line elements, is a fixed-width format that express the mean
elements of a object en Earth's orbit. They are used as input for the Simplified
General Perturbation Model 4 (SGP4 / SDP4) to propagate satellite orbits.

For more information about the TLE, see
[Two-line element set](https://en.wikipedia.org/wiki/Two-line_element_set).

## Installation

This package can be installed using:

``` julia
julia> using Pkg
julia> Pkg.add("SatelliteToolboxTle")
```

## Documentation

For more information, see the [documentation][docs-stable-url].

[docs-dev-url]: https://juliaspace.github.io/SatelliteToolboxTle.jl/dev
[docs-stable-url]: https://juliaspace.github.io/SatelliteToolboxTle.jl/stable
