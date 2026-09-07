## Description #############################################################################
#
# Define the functions for the TLE fetcher API.
#
############################################################################################

export create_tle_fetcher, fetch_tles

"""
    create_tle_fetcher(::Type{T}, args...; kwargs...) where {T <: AbstractTleFetcher} -> T

Create a TLE fetcher of type `T`.

The positional and keyword arguments are specific to each fetcher type; see the
documentation of the corresponding method. An `ArgumentError` is thrown if `T` has no
registered fetcher method.
"""
function create_tle_fetcher(::Type{T}, args...; kwargs...) where {T <: AbstractTleFetcher}
    return throw(ArgumentError("The TLE fetcher $T is not registered."))
end

"""
    fetch_tles(fetcher::T; kwargs...) where {T <: AbstractTleFetcher} -> Vector{TLE}

Fetch TLEs using `fetcher`.

The keywords `kwargs...` customize the search and are specific to each fetcher type; see
the documentation of the corresponding method. An `ArgumentError` is thrown if the fetcher
type `T` is not registered.
"""
function fetch_tles(::T; kwargs...) where {T <: AbstractTleFetcher}
    return throw(ArgumentError("The TLE fetcher $T is not registered."))
end
