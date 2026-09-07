# Auxiliary functions

```@meta
CurrentModule = SatelliteToolboxTle
```

```@setup auxiliary_functions
using SatelliteToolboxTle
```

This page describes some auxiliary functions in [SatelliteToolboxTle.jl](https://github.com/juliaspace/SatelliteToolboxTle.jl).

## TLE epoch

We can obtain the TLE epoch using the function [`tle_epoch`](@ref). It can return the epoch
in Julian Day, or as a `DateTime`, as follows:

```@repl auxiliary_functions
tle = tle"""
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       """;

tle_epoch(tle)

using Dates

tle_epoch(DateTime, tle)
```

The property `epoch` of the TLE is a shortcut for the latter:

```@repl auxiliary_functions
tle.epoch
```

The two-digit epoch year is interpreted according to the SGP4 reference implementation:
years from 57 to 99 refer to the 20th century, and years from 0 to 56 to the 21st century.

## Line checksum

The checksum of a TLE line can be computed using the function
[`tle_line_checksum`](@ref), which receives the line without the checksum digit:

```@repl auxiliary_functions
tle_line_checksum("1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  999")
```
