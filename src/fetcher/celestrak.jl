# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Create the Celestrak TLE fetcher.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export CelestrakTleFetcher

struct CelestrakTleFetcher <: AbstractTleFetcher
    url::String
end

"""
    create_tle_fetcher(::Type{CelestrakTleFetcher}; kwargs...) return CelestrakTleFetcher(url) end

Create a TLE fetcher from Celestrak service.

# Keywords

- `url::String`: Default PHP webpage address that will be used to perform the
  queries. (**Default**: "https://celestrak.org/NORAD/elements/gp.php")
"""
function create_tle_fetcher(
    ::Type{CelestrakTleFetcher};
    url::String = "https://celestrak.org/NORAD/elements/gp.php"
)
    return CelestrakTleFetcher(url)
end

"""
    fetch_tles(fetcher::CelestrakTleFetcher; international_designator::Union{Nothing, AbstractString} = nothing, satellite_number::Union{Nothing, Number} = nothing, satellite_name::Union{Nothing, AbstractString} = nothing,)

Fetch TLEs from the Celestrak using `fetch` with the parameters in `kwargs...`.

This function returns a `Vector{TLE}` with the fetched TLEs. If an error is
found, it returns `nothing`.

# Keywords

- `international_designator::Union{Nothing, AbstractString}`: International
    designator using the Celestrak format `YYYY-NNN`, where `YYYY` is the launch
    year, and the `NNN` is the launch number. (**Default**: `nothing`)
- `satellite_number::Union{Nothing, Number}`: Satellite catalog number (NORAD).
    (**Default** = `nothing`)
- `satellite_name::Union{Nothing, AbstractString}`: Satellite name. Notice that
    the system will search for all satellites whose name contains this string.
    (**Default**: `nothing`)

!!! note
    Only one search parameter is supported. If more than one is given, the
    precedence is: 1) `satellite_number`; 2) `international_designator`; and 3)
    and `satellite_name`.

!!! note
    If no search parameter is provided, the function throws an error.
"""
function fetch_tles(
    fetcher::CelestrakTleFetcher;
    international_designator::Union{Nothing, AbstractString} = nothing,
    satellite_number::Union{Nothing, Number} = nothing,
    satellite_name::Union{Nothing, AbstractString} = nothing,
)

    # Assemble the query string.
    if !isnothing(satellite_number)

        # The satellite number cannot have more than 9 digits and must be
        # positive.
        satellite_number <  0       && throw(ArgumentError("The satellite number must be positive."))
        satellite_number >= 100_000 && throw(ArgumentError("The satellite number must be lower than 100000."))

        query_type  = "satellite number"
        query_value = string(satellite_number)
        query_param = "CATNR=" * URIs.escapeuri(query_value)

    elseif !isnothing(international_designator)
        # The international designator must be a string with the form:
        #
        #   YYYY-NNN
        #
        # where `YYYY` is the launch year, and `NNN` is the launch number.

        isnothing(match(r"^[0-9]{4}-[0-9]{3}$", international_designator)) &&
            throw(ArgumentError("The international designator must have the format `YYYY-NNN`."))

        query_type  = "international designator"
        query_value = international_designator
        query_param = "INTDES=" * URIs.escapeuri(query_value)

    elseif !isnothing(satellite_name)
        isempty(satellite_name) && throw(ArgumentError("The satellite name is empty."))

        query_value = satellite_name
        query_param = "NAME=" * URIs.escapeuri(query_value)
        query_type  = "satellite name"

    else
        throw(ArgumentError("No query information was provided."))

    end

    @info "Fetch TLEs from Celestrak using $query_type: \"$query_value\" ..."

    # Assemble the URL.
    query = "?" * query_param * "&FORMAT=TLE"
    url = fetcher.url * query

    # Download the information into a buffer.
    buf = IOBuffer()
    @debug "Fetch URL: $url"
    Downloads.download(url, buf)
    str = String(take!(buf))

    # Check if some error occurred.
    if !isnothing(match(r"No GP data found", str))
        @warn "No GP data found."
        return TLE[]

    elseif !isnothing(match(r"Invalid query", str))
        throw(ErrorException("Invalid query: $query"))
        return nothing
    end

    # Parse the TLEs.
    tles = read_tles(str)

    return tles
end
