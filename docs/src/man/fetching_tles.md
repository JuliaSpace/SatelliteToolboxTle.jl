# Fetching TLEs

```@meta
CurrentModule = SatelliteToolboxTle
```

```@setup fetching_tles
using SatelliteToolboxTle
```

This package defines a simple API to fetch TLEs from different sources. For more
information, see the file `API.md` in the directory `./src/fetcher/`.

It already contains the support to [Celestrak](https://celestrak.org/). To fetch TLEs from
this source, we first need to create the fetcher object:

```@repl fetching_tles
f = create_tle_fetcher(CelestrakTleFetcher)
```

Afterward, we can fetch the TLEs using the function [`fetch_tles`](@ref):

```@repl fetching_tles
fetch_tles(f, satellite_name = "AMAZONIA 1")
```

This function will always return a `Vector{TLE}`, which is empty if no TLE matches the
query.

For Celestrak fetcher, the following options are available:

- `international_designator::Union{Nothing, AbstractString}`: International designator
    using the format `YYYY-NNN` or `YYYY-NNNP`, where `YYYY` is the launch year, `NNN` is
    the launch number, and `P` is the piece of the launch. (**Default**: `nothing`)
- `satellite_number::Union{Nothing, Integer}`: Satellite catalog number (NORAD).
    (**Default** = `nothing`)
- `satellite_name::Union{Nothing, AbstractString}`: Satellite name. Notice that the system
    will search for all satellites whose name contains this string.
    (**Default**: `nothing`)

!!! note

    Exactly one search parameter must be provided. Otherwise, the function throws an
    `ArgumentError`.

Thus, if we want to know, for example, all the satellites that were launched by the same
rocket, we can search by the international designator as follows:

```@repl fetching_tles
fetch_tles(f, international_designator = "2021-015")
```

If the request fails, for example because the service is unreachable, the function throws
a [`TleFetchError`](@ref) with the URL and, if available, the HTTP status of the request.

!!! warning

    Please, **DO NOT** abuse the fetching system. CelesTrak is a non-profit organization.
    [SatelliteToolboxTle.jl](https://github.com/juliaspace/SatelliteToolboxTle.jl) provides
    only the interface to their servers. Ensure you agree with their user agreement before
    using the functions described here. Abusing the GP data API can lead to bans.
