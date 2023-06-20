Fetching TLEs
=============

```@meta
CurrentModule = SatelliteToolboxTle
DocTestSetup = quote
    using SatelliteToolboxTle
end
```

This package defines a simple API to fetch TLEs from different sources. For more
information, see the file `API.md` in the directory `./src/fetcher/`.

It already contains the support to [Celestrak](https://celestrak.org/). To fetch TLEs from
this source, we first need to create the fetcher object:

```jldoctest fetching_tles
julia> f = create_tle_fetcher(CelestrakTleFetcher)
CelestrakTleFetcher("https://celestrak.org/NORAD/elements/gp.php")
```

Afterward, we can fetch the TLEs using the function [`fetch_tles`](@ref):

```julia
julia> fetch_tles(f, satellite_name = "AMAZONIA 1")
[ Info: Fetch TLEs from Celestrak using satellite name: "AMAZONIA 1" ...
1-element Vector{TLE}:
 TLE: AMAZONIA 1 (Epoch = 2023-03-28T05:28:43.099)
```

This function will always return a `Vector{TLE}`.

For Celestrak fetcher, the following options are available:

- `international_designator::Union{Nothing, AbstractString}`: International designator using
    the Celestrak format `YYYY-NNN`, where `YYYY` is the launch year, and the `NNN` is the
    launch number. (**Default**: `nothing`)
- `satellite_number::Union{Nothing, Number}`: Satellite catalog number (NORAD).
    (**Default** = `nothing`)
- `satellite_name::Union{Nothing, AbstractString}`: Satellite name. Notice that the system
    will search for all satellites whose name contains this string.
    (**Default**: `nothing`)

!!! note
    Only one search parameter is supported. If more than one is given, the precedence is: 1)
    `satellite_number`; 2) `international_designator`; and 3) and `satellite_name`.

!!! note
    If no search parameter is provided, the function throws an error.

Thus, if we want to know, for example, all the satellites that were launched by the same
rocket, we can search by the international designator as follows:

```julia
julia> fetch_tles(f, international_designator = "2021-015")
[ Info: Fetch TLEs from Celestrak using international designator: "2021-015" ...
8-element Vector{TLE}:
 TLE: AMAZONIA 1 (Epoch = 2023-03-28T05:28:43.099)
 TLE: OBJECT B (Epoch = 2023-03-28T03:55:03.696)
 TLE: SAI-1 NANOCONNECT-2 (Epoch = 2023-03-28T05:20:11.308)
 TLE: SINE (SINDHUNETRA) (Epoch = 2023-03-28T15:49:01.492)
 TLE: OBJECT S (Epoch = 2023-03-28T10:41:32.722)
 TLE: OBJECT T (Epoch = 2023-03-28T04:32:52.552)
 TLE: OBJECT U (Epoch = 2023-03-28T11:38:14.139)
 TLE: SDSAT (Epoch = 2023-03-28T13:22:20.912)
```

!!! warning
    Please, **DO NOT** abuse the fetching system. CelesTrak is a non-profit organization.
    [SatelliteToolboxTle.jl](https://github.com/juliaspace/SatelliteToolboxTle.jl) provides
    only the interface to their servers. Ensure you agree with their user agreement before
    using the functions described here. Abusing the GP data API can lead to bans.
