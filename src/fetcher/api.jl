# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Define the functions for the TLE fetcher API.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export create_tle_fetcher, fetch_tles

"""
    create_tle_fetcher(::Type{T}, args...; kwargs...) where T <: AbstractTleFetcher -> T

Create a TLE fetcher of type `T`.
"""
function create_tle_fetcher(::Type{T}, args...; kwargs...) where T <: AbstractTleFetcher
    error("The TLE fetcher $T is not registered.")
end

"""
    fetch_tles(fetcher::T; kwargs...) -> Vector{TLE}

Fetch TLEs using `fetcher`.

The keywords `kwargs...` are used to customize the search. It depends on the fetcher type
`T`.
"""
function fetch_tles(::T; kwargs...) where T <: AbstractTleFetcher
    error("The TLE fetcher $T is not registered.")
end
