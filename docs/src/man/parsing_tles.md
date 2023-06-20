Parsing TLEs
============

```@meta
CurrentModule = SatelliteToolboxTle
DocTestSetup = quote
    using SatelliteToolboxTle
end
```

This package contains functions to parse TLEs from strings and files.

## Parsing TLEs from strings

The simplest way to parse one single TLE is using the macro [`@tle_str`](@ref):

```jldoctest
julia> tle = tle"""
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       """
TLE:
                      Name : AMAZONIA 1
          Satellite number : 47699
  International designator : 21015A
        Epoch (Year / Day) : 23 /  83.68657856 (2023-03-24T16:28:40.388)
        Element set number : 999
              Eccentricity :   0.00012470
               Inclination :  98.43040000 deg
                      RAAN : 162.10970000 deg
       Argument of perigee : 136.20170000 deg
              Mean anomaly : 223.92830000 deg
           Mean motion (n) :  14.40814394 revs / day
         Revolution number : 10865
                        B* :      4.3e-05 1 / er
                     ṅ / 2 :     -4.4e-07 rev / day²
                     n̈ / 6 :        1e-09 rev / day³
```

This macro considers only one TLE, leading to an error if the string contains additional
information:

```julia
julia> tle = tle"""
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       CBERS 4A
       1 44883U 19093E   23087.54098578  .00002943  00000+0  38100-3 0  9997
       2 44883  97.8669 167.4611 0001705  77.3129 282.8275 14.81612352176856
       """
ERROR: LoadError: ArgumentError: The string `str` must contain only one TLE (2 or 3 lines).
Stacktrace:
 [1] read_tle(str::String; verify_checksum::Bool)
   @ SatelliteToolboxTle ~/.julia/dev/SatelliteToolboxTle/src/read.jl:161
 [2] var"@tle_str"(__source__::LineNumberNode, __module__::Module, str::Any)
   @ SatelliteToolboxTle ~/.julia/dev/SatelliteToolboxTle/src/read.jl:43
in expression starting at REPL[3]:1
```

Multiple TLEs can be parsed using the macro [`@tles_str`](@ref):

```jldoctest
julia> tles = tles"""
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       CBERS 4A
       1 44883U 19093E   23087.54098578  .00002943  00000+0  38100-3 0  9997
       2 44883  97.8669 167.4611 0001705  77.3129 282.8275 14.81612352176856
       """
2-element Vector{TLE}:
 TLE: AMAZONIA 1 (Epoch = 2023-03-24T16:28:40.388)
 TLE: CBERS 4A (Epoch = 2023-03-28T12:59:01.171)
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

```jldoctest
julia> tle_str = """
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       """;

julia> read_tle(tle_str)
TLE:
                      Name : AMAZONIA 1
          Satellite number : 47699
  International designator : 21015A
        Epoch (Year / Day) : 23 /  83.68657856 (2023-03-24T16:28:40.388)
        Element set number : 999
              Eccentricity :   0.00012470
               Inclination :  98.43040000 deg
                      RAAN : 162.10970000 deg
       Argument of perigee : 136.20170000 deg
              Mean anomaly : 223.92830000 deg
           Mean motion (n) :  14.40814394 revs / day
         Revolution number : 10865
                        B* :      4.3e-05 1 / er
                     ṅ / 2 :     -4.4e-07 rev / day²
                     n̈ / 6 :        1e-09 rev / day³

julia> tles_str = """
       AMAZONIA 1
       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
       2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
       CBERS 4A
       1 44883U 19093E   23087.54098578  .00002943  00000+0  38100-3 0  9997
       2 44883  97.8669 167.4611 0001705  77.3129 282.8275 14.81612352176856
       """;

julia> tles = read_tles(tles_str)
2-element Vector{TLE}:
 TLE: AMAZONIA 1 (Epoch = 2023-03-24T16:28:40.388)
 TLE: CBERS 4A (Epoch = 2023-03-28T12:59:01.171)
```

If the user does not want checksum verification, pass the keyword `verify_checksum = false`.

## Parsing TLEs from files

We can parse TLEs in files using the function [`read_tles_from_file`](@ref):

```julia
julia> tles = read_tles_from_file("samples.tle")
2-element Vector{TLE}:
 TLE: AMAZONIA 1 (Epoch = 2023-03-24T16:28:40.388)
 TLE: CBERS 4A (Epoch = 2023-03-25T12:02:42.585)
```

This function will always return a `Vector{TLE}`.
