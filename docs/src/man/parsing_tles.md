# Parsing TLEs

```@meta
CurrentModule = SatelliteToolboxTle
```

```@setup parsing_tles
using SatelliteToolboxTle
```

This package contains functions to parse TLEs from strings and files.

## Parsing TLEs from strings

The simplest way to parse one single TLE is using the macro [`@tle_str`](@ref):

```@repl parsing_tles
tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """
```

This macro considers only one TLE, leading to an error if the string contains additional
information:

```@repl parsing_tles
tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    CBERS 4A
    1 44883U 19093E   23087.54098578  .00002943  00000+0  38100-3 0  9997
    2 44883  97.8669 167.4611 0001705  77.3129 282.8275 14.81612352176856
    """
```

Multiple TLEs can be parsed using the macro [`@tles_str`](@ref):

```@repl parsing_tles
tles = tles"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    CBERS 4A
    1 44883U 19093E   23087.54098578  .00002943  00000+0  38100-3 0  9997
    2 44883  97.8669 167.4611 0001705  77.3129 282.8275 14.81612352176856
    """
```

In this case, the result will always be a `Vector{TLE}`.

!!! note

    We distinguished the parsing algorithm of one or multiple TLEs to avoid unnecessary
    allocations in the former.

[`@tle_str`](@ref) and [`@tles_str`](@ref) will always check the checksum of the two lines.
If this verification is not desired, use the versions [`@tle_nc_str`](@ref) and
[`@tles_nc_str`](@ref).

If the TLE is programmatically added to a string, it can be parsed using the functions
[`read_tle`](@ref) and [`read_tles`](@ref) for one or multiple TLEs, respectively.

```@repl parsing_tles
tle_str = """
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

read_tle(tle_str)

tles_str = """
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    CBERS 4A
    1 44883U 19093E   23087.54098578  .00002943  00000+0  38100-3 0  9997
    2 44883  97.8669 167.4611 0001705  77.3129 282.8275 14.81612352176856
    """

tles = read_tles(tles_str)
```

If the user does not want checksum verification, pass the keyword `verify_checksum = false`.

## Parsing TLEs from files

We can parse TLEs in files using the function [`read_tles_from_file`](@ref):

```@repl parsing_tles
tles = read_tles_from_file("samples.tle")
```

This function will always return a `Vector{TLE}`.
