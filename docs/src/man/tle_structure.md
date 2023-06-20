# [The TLE structure](@id tle_structure)

When a TLE is parsed using this package, the information is encapsulated in the structure
[`TLE`](@ref). Its fields are:

- `name::String`: Name of the satellite.
- `satellite_number::Int`: Satellite number.
- `classification::Char`: Classification ('U', 'C', or 'S').
- `international_designator::String`: International designator.
- `epoch_year::Int`: Epoch year (two digits).
- `epoch_day::Float64`: Epoch day (day + fraction of the day).
- `dn_o2::Float64`: 1st time derivative of mean motion / 2 [rev/day²].
- `ddn_o6::Float64`: 2nd time derivative of mean motion / 6 [rev/day³].
- `bstar::Float64`: B* drag term.
- `element_set_number::Int`: Element set number.
- `incliantion::Float64`: Inclination [deg].
- `raan::Float64`: Right ascension of the ascending node [deg].
- `eccentricity::Float64`: Eccentricity [ ].
- `argument_of_perigee::Float64`: Argument of perigee [deg].
- `mean_anomaly::Float64`: Mean anomaly [deg].
- `mean_motion::Float64`: Mean motion [rev/day].
- `revolution_number::Int`: Revolution number at epoch [rev].

Notice that we preserve the units of the TLE definition.
