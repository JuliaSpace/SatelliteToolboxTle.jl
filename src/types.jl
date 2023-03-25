# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Types and structures of TLE.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export TLE

"""
    struct TLE

Store the elements of a TLE (two-line elemens) using the same units.

!!! note
    We do not have fields for the line checksum since they are only required
    when creating or parsing a TLE string.

# Fields

- `name`: Name of the satellite.

## First line

- `satellite_number`: Satellite number.
- `classification`: Classification ('U', 'C', or 'S').
- `international_designator`: International designator.
- `epoch_year`: Epoch year (two digits).
- `epoch_day`: Epoch day (day + fraction of the day).
- `dn_o2`: 1st time derivative of mean motion / 2 [rev/day²].
- `ddn_o6`: 2nd time derivative of mean motion / 6 [rev/day³].
- `bstar`: B* drag term.
- `element_set_number`: Element set number.

## Second line

- `incliantion`: Inclination [deg].
- `raan`: Right ascension of the ascending node [deg].
- `eccentricity`: Eccentricity [ ].
- `argument_of_perigee`: Argument of perigee [deg].
- `mean_anomaly`: Mean anomaly [deg].
- `mean_motion`: Mean motion [rev/day].
- `revolution_number`: Revolution number at epoch [rev].

# Creating TLEs

You can manually create a `TLE` by calling the function `TLE(; kwargs...)`,
where `kwargs...` are keyword arguments with the same name as the fields. In
this case, the following elements are required:

- `epoch_year`, `epoch_day`, `inclination`, `raan`, `eccentricity`,
    `argument_of_perigee`, `mean_anomaly` and `mean_motion`.

The other ones are optional and default values will be assigned if not present.
"""
Base.@kwdef struct TLE
    name::String = "UNDEFINED"

    # First line
    # ==========================================================================

    satellite_number::Int = 0
    classification::Char = 'U'
    international_designator::String = "00000"
    epoch_year::Int
    epoch_day::Float64
    dn_o2::Float64 = 0
    ddn_o6::Float64 = 0
    bstar::Float64 = 0
    element_set_number::Int = 0

    # Second line
    # ==========================================================================

    inclination::Float64
    raan::Float64
    eccentricity::Float64
    argument_of_perigee::Float64
    mean_anomaly::Float64
    mean_motion::Float64
    revolution_number::Int = 0
end
