# SatelliteToolboxTle.jl

This package allows creating, fetching, and parsing TLEs (two-line elements).

## Two-line elements

The TLE, or two-line elements, is a fixed-width format that express the mean elements of a
object in Earth's orbit. They are used as input for the Simplified General Perturbation
Model 4 (SGP4 / SDP4) to propagate satellite orbits.

For more information about the TLE, see
[Two-line element set](https://en.wikipedia.org/wiki/Two-line_element_set).

## Installation

This package can be installed using:

```julia-repl
julia> using Pkg
julia> Pkg.add("SatelliteToolboxTle")
```
