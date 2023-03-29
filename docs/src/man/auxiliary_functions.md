Auxiliary functions
===================

```@meta
CurrentModule = SatelliteToolboxTle
DocTestSetup = quote
    using SatelliteToolboxTle
end
```

This page describes some auxiliary functions in [SatelliteToolboxTle.jl](https://github.com/juliaspace/SatelliteToolboxTle.jl).

## TLE epoch

We can obtain the TLE epoch using the function [`tle_epoch`](@ref). It can
return the epoch in Julian Day, or as a `DateTime`, as follows:

```jldoctest
julia> tle = tle"""
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       """;

julia> tle_epoch(tle)
2.46002818657856e6

julia> using Dates

julia> tle_epoch(DateTime, tle)
2023-03-24T16:28:40.388
```
