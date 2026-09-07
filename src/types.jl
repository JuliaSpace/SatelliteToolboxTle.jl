## Description #############################################################################
#
# Types and structures of TLE.
#
############################################################################################

export TLE, AbstractTleFetcher, TleParseError, TleFetchError

############################################################################################
#                                        Exceptions                                        #
############################################################################################

"""
    struct TleParseError <: Exception

Exception thrown when a TLE cannot be parsed from its text representation.

# Fields

- `msg::String`: Description of the parsing failure.
- `line::Int`: Number of the line in the input where the failure was detected, or `0` if
    the position is unknown.
"""
struct TleParseError <: Exception
    msg::String
    line::Int
end

"""
    TleParseError(msg::String; kwargs...) -> TleParseError

Create a [`TleParseError`](@ref) with the description `msg`.

# Keywords

- `line::Int`: Number of the line in the input where the failure was detected, or `0` if
    the position is unknown.
    (**Default**: `0`)
"""
TleParseError(msg::String; line::Int = 0) = TleParseError(msg, line)

function Base.showerror(io::IO, e::TleParseError)
    print(io, "TleParseError: ")
    e.line > 0 && print(io, "[Line ", e.line, "]: ")
    print(io, e.msg)
    return nothing
end

"""
    struct TleFetchError <: Exception

Exception thrown when a request to a TLE service fails.

# Fields

- `msg::String`: Description of the request failure.
- `url::Union{String, Nothing}`: URL of the failed request, if available.
- `status::Union{Int, Nothing}`: HTTP status code of the failed request, if available.
"""
struct TleFetchError <: Exception
    msg::String
    url::Union{String, Nothing}
    status::Union{Int, Nothing}
end

"""
    TleFetchError(msg::String; kwargs...) -> TleFetchError

Create a [`TleFetchError`](@ref) with the description `msg`.

# Keywords

- `url::Union{String, Nothing}`: URL of the failed request, if available.
    (**Default**: `nothing`)
- `status::Union{Int, Nothing}`: HTTP status code of the failed request, if available.
    (**Default**: `nothing`)
"""
function TleFetchError(
    msg::String;
    url::Union{String, Nothing} = nothing,
    status::Union{Int, Nothing} = nothing,
)
    return TleFetchError(msg, url, status)
end

function Base.showerror(io::IO, e::TleFetchError)
    print(io, "TleFetchError: ", e.msg)
    isnothing(e.status) || print(io, " (HTTP status: ", e.status, ")")
    isnothing(e.url) || print(io, "\nURL: ", e.url)
    return nothing
end

############################################################################################
#                                           TLE                                            #
############################################################################################

"""
    struct TLE

Store the elements of a TLE (two-line elements) using the same units of the TLE format.

The inner constructor enforces that every field can be represented in the fixed-width TLE
format (see the ranges below), so that writing a `TLE` never fails. Create a `TLE` with the
keyword constructor `TLE(; kwargs...)`, whose keywords are the fields below plus the
optional `epoch`.

!!! note

    We do not have fields for the line checksums since they are only required when writing
    or parsing a TLE string.

# Fields

- `name::String`: Name of the satellite.
    (**Default**: `"UNDEFINED"`)

## First line

- `satellite_number::Int`: Satellite catalog number, in the interval [0, 339999]. Numbers
    above 99999 are written using the Alpha-5 scheme.
    (**Default**: `0`)
- `classification::Char`: Classification (`'U'`, `'C'`, or `'S'`). It must be an ASCII
    character.
    (**Default**: `'U'`)
- `international_designator::String`: International designator, with at most 8 ASCII
    characters.
    (**Default**: `"00000"`)
- `epoch_year::Int`: Epoch year, with two digits in the interval [0, 99]. Years from 57 to
    99 refer to the 20th century, and years from 0 to 56 to the 21st century.
- `epoch_day::Float64`: Epoch day of the year plus its fraction, in the interval [0, 367)
    [days].
- `dn_o2::Float64`: 1st time derivative of the mean motion divided by 2 [rev/day²].
    (**Default**: `0`)
- `ddn_o6::Float64`: 2nd time derivative of the mean motion divided by 6 [rev/day³].
    (**Default**: `0`)
- `bstar::Float64`: B* drag term [1/ER].
    (**Default**: `0`)
- `ephemeris_type::Int`: Ephemeris type, with one digit in the interval [0, 9].
    (**Default**: `0`)
- `element_set_number::Int`: Element set number, in the interval [0, 9999].
    (**Default**: `0`)

## Second line

- `inclination::Float64`: Inclination [°].
- `raan::Float64`: Right ascension of the ascending node [°].
- `eccentricity::Float64`: Eccentricity [-], in the interval [0, 1).
- `argument_of_perigee::Float64`: Argument of perigee [°].
- `mean_anomaly::Float64`: Mean anomaly [°].
- `mean_motion::Float64`: Mean motion [rev/day], in the interval [0, 100).
- `revolution_number::Int`: Revolution number at epoch [rev], in the interval [0, 99999].
    (**Default**: `0`)

# Extended help

## Properties

Besides the fields, the property `epoch` returns the TLE epoch as a `DateTime` [UTC], as
computed by [`tle_epoch`](@ref).

## Creating TLEs

The keyword constructor `TLE(; kwargs...)` requires `inclination`, `raan`, `eccentricity`,
`argument_of_perigee`, `mean_anomaly`, and `mean_motion`. The epoch must be provided either
by `epoch_year` and `epoch_day`, or by the keyword `epoch::DateTime` [UTC], from which the
former are computed. The other keywords are optional and receive the default values listed
above.

## Throws

- `ArgumentError`: If a field is outside the range that can be represented in the TLE
    format, or if the epoch is not provided exactly once.
"""
struct TLE
    name::String

    # == First Line ========================================================================

    satellite_number::Int
    classification::Char
    international_designator::String
    epoch_year::Int
    epoch_day::Float64
    dn_o2::Float64
    ddn_o6::Float64
    bstar::Float64
    ephemeris_type::Int
    element_set_number::Int

    # == Second Line =======================================================================

    inclination::Float64
    raan::Float64
    eccentricity::Float64
    argument_of_perigee::Float64
    mean_anomaly::Float64
    mean_motion::Float64
    revolution_number::Int

    # == Constructors ======================================================================

    function TLE(
        name::AbstractString,
        satellite_number::Integer,
        classification::Char,
        international_designator::AbstractString,
        epoch_year::Integer,
        epoch_day::Number,
        dn_o2::Number,
        ddn_o6::Number,
        bstar::Number,
        ephemeris_type::Integer,
        element_set_number::Integer,
        inclination::Number,
        raan::Number,
        eccentricity::Number,
        argument_of_perigee::Number,
        mean_anomaly::Number,
        mean_motion::Number,
        revolution_number::Integer,
    )
        # Verify that every field can be represented in the fixed-width TLE format.
        #! format: off
        0 <= satellite_number <= _MAX_SATELLITE_NUMBER || throw(ArgumentError(
            "The satellite number must be in the interval [0, $_MAX_SATELLITE_NUMBER]."
        ))
        isascii(classification) || throw(ArgumentError(
            "The classification must be an ASCII character."
        ))
        (isascii(international_designator) && (sizeof(international_designator) <= 8)) ||
            throw(ArgumentError(
                "The international designator must have at most 8 ASCII characters."
            ))
        0 <= epoch_year <= 99 || throw(ArgumentError(
            "The epoch year must be in the interval [0, 99]."
        ))
        0 <= epoch_day < 367 || throw(ArgumentError(
            "The epoch day must be in the interval [0, 367)."
        ))
        0 <= ephemeris_type <= 9 || throw(ArgumentError(
            "The ephemeris type must be in the interval [0, 9]."
        ))
        0 <= element_set_number <= 9999 || throw(ArgumentError(
            "The element set number must be in the interval [0, 9999]."
        ))
        0 <= eccentricity < 1 || throw(ArgumentError(
            "The eccentricity must be in the interval [0, 1)."
        ))
        0 <= mean_motion < 100 || throw(ArgumentError(
            "The mean motion must be in the interval [0, 100)."
        ))
        0 <= revolution_number <= 99_999 || throw(ArgumentError(
            "The revolution number must be in the interval [0, 99999]."
        ))
        #! format: on

        return new(
            name,
            satellite_number,
            classification,
            international_designator,
            epoch_year,
            epoch_day,
            dn_o2,
            ddn_o6,
            bstar,
            ephemeris_type,
            element_set_number,
            inclination,
            raan,
            eccentricity,
            argument_of_perigee,
            mean_anomaly,
            mean_motion,
            revolution_number,
        )
    end
end

"""
    TLE(; kwargs...) -> TLE

Create a [`TLE`](@ref) from the keyword arguments `kwargs...`, which have the same names as
the structure fields, plus the optional keyword `epoch`.

The keywords `inclination`, `raan`, `eccentricity`, `argument_of_perigee`, `mean_anomaly`,
and `mean_motion` are required. The epoch must be provided either by `epoch_year` and
`epoch_day`, or by `epoch`, from which the former are computed. The other keywords are
optional. An `ArgumentError` is thrown if a field cannot be represented in the TLE format
or if the epoch is not provided exactly once.

# Keywords

- `name::AbstractString`: Name of the satellite.
    (**Default**: `"UNDEFINED"`)
- `satellite_number::Integer`: Satellite catalog number, in the interval [0, 339999].
    (**Default**: `0`)
- `classification::Char`: Classification (`'U'`, `'C'`, or `'S'`).
    (**Default**: `'U'`)
- `international_designator::AbstractString`: International designator, with at most 8
    ASCII characters.
    (**Default**: `"00000"`)
- `epoch::Union{DateTime, Nothing}`: Epoch [UTC] used to compute `epoch_year` and
    `epoch_day`. It cannot be provided together with those keywords.
    (**Default**: `nothing`)
- `epoch_year::Union{Integer, Nothing}`: Epoch year with two digits, in the interval
    [0, 99]. It is required if `epoch` is not provided.
    (**Default**: `nothing`)
- `epoch_day::Union{Number, Nothing}`: Epoch day of the year plus its fraction, in the
    interval [0, 367) [days]. It is required if `epoch` is not provided.
    (**Default**: `nothing`)
- `dn_o2::Number`: 1st time derivative of the mean motion divided by 2 [rev/day²].
    (**Default**: `0`)
- `ddn_o6::Number`: 2nd time derivative of the mean motion divided by 6 [rev/day³].
    (**Default**: `0`)
- `bstar::Number`: B* drag term [1/ER].
    (**Default**: `0`)
- `ephemeris_type::Integer`: Ephemeris type, in the interval [0, 9].
    (**Default**: `0`)
- `element_set_number::Integer`: Element set number, in the interval [0, 9999].
    (**Default**: `0`)
- `inclination::Number`: Inclination [°].
- `raan::Number`: Right ascension of the ascending node [°].
- `eccentricity::Number`: Eccentricity [-], in the interval [0, 1).
- `argument_of_perigee::Number`: Argument of perigee [°].
- `mean_anomaly::Number`: Mean anomaly [°].
- `mean_motion::Number`: Mean motion [rev/day], in the interval [0, 100).
- `revolution_number::Integer`: Revolution number at epoch [rev], in the interval
    [0, 99999].
    (**Default**: `0`)
"""
function TLE(;
    name::AbstractString = "UNDEFINED",
    satellite_number::Integer = 0,
    classification::Char = 'U',
    international_designator::AbstractString = "00000",
    epoch::Union{DateTime, Nothing} = nothing,
    epoch_year::Union{Integer, Nothing} = nothing,
    epoch_day::Union{Number, Nothing} = nothing,
    dn_o2::Number = 0,
    ddn_o6::Number = 0,
    bstar::Number = 0,
    ephemeris_type::Integer = 0,
    element_set_number::Integer = 0,
    inclination::Number,
    raan::Number,
    eccentricity::Number,
    argument_of_perigee::Number,
    mean_anomaly::Number,
    mean_motion::Number,
    revolution_number::Integer = 0,
)
    # The epoch must be provided either by `epoch` or by `epoch_year` and `epoch_day`.
    if !isnothing(epoch)
        (isnothing(epoch_year) && isnothing(epoch_day)) || throw(
            ArgumentError(
                "The keyword `epoch` cannot be provided together with `epoch_year` or " *
                "`epoch_day`.",
            ),
        )

        epoch_year, epoch_day = _datetime_to_tle_epoch(epoch)

    elseif isnothing(epoch_year) || isnothing(epoch_day)
        throw(
            ArgumentError(
                "The epoch must be provided either by the keyword `epoch` or by the " *
                "keywords `epoch_year` and `epoch_day`.",
            ),
        )
    end

    return TLE(
        name,
        satellite_number,
        classification,
        international_designator,
        epoch_year,
        epoch_day,
        dn_o2,
        ddn_o6,
        bstar,
        ephemeris_type,
        element_set_number,
        inclination,
        raan,
        eccentricity,
        argument_of_perigee,
        mean_anomaly,
        mean_motion,
        revolution_number,
    )
end

# == Properties ============================================================================

# The property `epoch` returns the TLE epoch as a `DateTime`.
function Base.getproperty(tle::TLE, name::Symbol)
    name === :epoch && return tle_epoch(DateTime, tle)
    return getfield(tle, name)
end

Base.propertynames(::TLE) = (fieldnames(TLE)..., :epoch)

############################################################################################
#                                       TLE Fetcher                                        #
############################################################################################

"""
    abstract type AbstractTleFetcher

Abstract type for all TLE fetchers.
"""
abstract type AbstractTleFetcher end
