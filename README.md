<p align="center">
  <img src="./docs/src/assets/logo.png" width="150" title="SatelliteToolboxTransformations.jl"><br>
  <small><i>This package is part of the <a href="https://github.com/JuliaSpace/SatelliteToolbox.jl">SatelliteToolbox.jl</a> ecosystem.</i></small>
</p>

SatelliteToolboxTle.jl
======================

[![CI](https://github.com/JuliaSpace/SatelliteToolboxTle.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaSpace/SatelliteToolboxTle.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTle.jl/branch/main/graph/badge.svg?token=SPIKBIN3ES)](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTle.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)][docs-stable-url]
[![](https://img.shields.io/badge/docs-dev-blue.svg)][docs-dev-url]
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This package allows creating, fetching, and parsing TLEs (two-line elements).

## Two-line elements

The TLE, or two-line elements, is a fixed-width format that express the mean
elements of a object in Earth's orbit. They are used as input for the Simplified
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
