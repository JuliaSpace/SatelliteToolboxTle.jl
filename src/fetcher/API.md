SatelliteToolboxTle.jl fetcher API
==================================

This document describes the API for services that fetches TLEs from a source.

## Definition

A TLE fetcher must be defined using a structure with super-type
`AbstractTleFetcher`, for example:

```julia
struct MyTleFetcher <: AbstractTleFetcher
    ...
end
```

The structure can have any field required for the operation. Those fields will
be assigned when the fetcher is created.

## Creating the fetcher

The fetcher must overload the function `create_tle_fetcher` to create an object
with the fetcher's type, defined in the previous section. The API of this
function is:

```julia
create_tle_fetcher(::Type{T}, args...; kwargs...) where T <: AbstractTleFetcher
```

The `args...` and `kwargs...` can be selected depending on the required
information for the TLE fetcher.

## Fetching TLEs

The fetcher must overload the function `fetch_tle` that will fetch TLEs from the
source. The API is:

```julia
fetch_tle(::T; kwargs...)::Vector{TLE}
```

The `kwargs...` should be selected to provide the search fields for the fetcher.
This function must return a vector of `TLE` with the fetched data.
