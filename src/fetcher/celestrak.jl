## Description #############################################################################
#
# Create the Celestrak TLE fetcher.
#
############################################################################################

export CelestrakTleFetcher

"""
    struct CelestrakTleFetcher <: AbstractTleFetcher

Fetcher that retrieves TLEs from the [Celestrak](https://celestrak.org) service.

Create an instance with
[`create_tle_fetcher(CelestrakTleFetcher)`](@ref create_tle_fetcher) and query the service
with [`fetch_tles`](@ref). Celestrak provides publicly available data and does not require
authentication.

# Fields

- `url::String`: Address of the Celestrak endpoint used to perform the queries.
"""
struct CelestrakTleFetcher <: AbstractTleFetcher
    url::String
end

############################################################################################
#                                        Overloads                                         #
############################################################################################

function show(io::IO, fetcher::CelestrakTleFetcher)
    print(io, "CelestrakTleFetcher: ", fetcher.url)
    return nothing
end

############################################################################################
#                                     Public Functions                                     #
############################################################################################

"""
    create_tle_fetcher(::Type{CelestrakTleFetcher}; kwargs...) -> CelestrakTleFetcher

Create a TLE fetcher from the Celestrak service.

# Keywords

- `url::String`: URL of the Celestrak query endpoint.
    (**Default**: `"https://celestrak.org/NORAD/elements/gp.php"`)
"""
function create_tle_fetcher(
    ::Type{CelestrakTleFetcher}; url::String = "https://celestrak.org/NORAD/elements/gp.php"
)
    return CelestrakTleFetcher(url)
end

"""
    fetch_tles(fetcher::CelestrakTleFetcher; kwargs...) -> Vector{TLE}

Fetch TLEs from the Celestrak service using the query parameters in `kwargs...`.

Exactly one of `international_designator`, `satellite_number`, and `satellite_name` must
be provided. If no matching TLE is found, an empty vector is returned with a warning. If
an error prevents the request from succeeding, a [`TleFetchError`](@ref) is thrown.

!!! warning

    Please, **do not** abuse the fetching system. CelesTrak is a non-profit organization,
    and abusing its GP data API can lead to bans.

# Keywords

- `international_designator::Union{Nothing, AbstractString}`: International designator of
    the satellite in the format `YYYY-NNN` or `YYYY-NNNP`, where `YYYY` is the launch
    year, `NNN` is the launch number, and `P` is the piece of the launch.
    (**Default**: `nothing`)
- `satellite_number::Union{Nothing, Integer}`: Satellite catalog number (NORAD).
    (**Default**: `nothing`)
- `satellite_name::Union{Nothing, AbstractString}`: Satellite name. The service returns
    every satellite whose name contains this string.
    (**Default**: `nothing`)

# Extended help

## Throws

- `ArgumentError`: If the number of query parameters is not exactly one, or if a query
    parameter is not valid.
- `TleFetchError`: If the request fails or if the service rejects the query.
"""
function fetch_tles(
    fetcher::CelestrakTleFetcher;
    international_designator::Union{Nothing, AbstractString} = nothing,
    satellite_number::Union{Nothing, Integer} = nothing,
    satellite_name::Union{Nothing, AbstractString} = nothing,
)
    selector_count = count(
        !isnothing, (satellite_number, international_designator, satellite_name)
    )
    selector_count == 1 ||
        throw(ArgumentError("Exactly one query parameter must be provided."))

    # == Assemble the Query String =========================================================

    if !isnothing(satellite_number)
        (0 < satellite_number <= _MAX_SATELLITE_NUMBER) || throw(
            ArgumentError(
                "The satellite number must be in the interval [1, $_MAX_SATELLITE_NUMBER]."
            ),
        )

        query_type  = "satellite number"
        query_value = string(satellite_number)
        query_param = "CATNR=" * URIs.escapeuri(query_value)

    elseif !isnothing(international_designator)
        m = match(r"^(\d{4})-(\d{1,3})([A-Z]*)$", strip(international_designator))

        isnothing(m) && throw(
            ArgumentError(
                "The international designator must have the format `YYYY-NNN` or " *
                "`YYYY-NNNP`.",
            ),
        )

        # The launch number must be padded to 3 digits as expected by Celestrak.
        query_type  = "international designator"
        query_value = string(m[1], "-", lpad(m[2], 3, '0'), m[3])
        query_param = "INTDES=" * URIs.escapeuri(query_value)

    else
        isempty(satellite_name) && throw(ArgumentError("The satellite name is empty."))

        query_type  = "satellite name"
        query_value = String(satellite_name)
        query_param = "NAME=" * URIs.escapeuri(query_value)
    end

    @info("Fetching TLEs from Celestrak using $query_type \"$query_value\"...")

    # Assemble the URL, preserving any query parameter already present in the endpoint.
    base_uri = URIs.URI(fetcher.url)
    query    = isempty(base_uri.query) ? "" : base_uri.query * "&"
    query   *= query_param * "&FORMAT=TLE"
    url      = string(URIs.URI(base_uri; query = query))

    # == Download the Data =================================================================

    @debug("Fetch URL: $url")

    buf = IOBuffer()

    try
        Downloads.download(url, buf)
    catch e
        e isa Downloads.RequestError || rethrow(e)

        # The status is 0 when the failure is not related to the HTTP response.
        status = e.response.status

        throw(
            TleFetchError(
                "The Celestrak request failed: $(e.message)";
                url = url,
                status = status > 0 ? status : nothing,
            ),
        )
    end

    str = String(take!(buf))

    # Check if the service reported an error.
    if occursin("No GP data found", str)
        @warn("No TLE found.")
        return TLE[]

    elseif occursin("Invalid query", str)
        throw(TleFetchError("Invalid query: $query"; url = url))
    end

    return read_tles(str)
end
