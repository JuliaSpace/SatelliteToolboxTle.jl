# [The TLE structure](@id tle_structure)

```@meta
CurrentModule = SatelliteToolboxTle
```

When a TLE is parsed using this package, the information is encapsulated in the structure
[`TLE`](@ref). Its fields are:

- `name::String`: Name of the satellite.
- `satellite_number::Int`: Satellite catalog number, in the interval [0, 339999]. Numbers
  above 99999 are written using the Alpha-5 scheme.
- `classification::Char`: Classification ('U', 'C', or 'S').
- `international_designator::String`: International designator, with at most 8 characters.
- `epoch_year::Int`: Epoch year (two digits). Years from 57 to 99 refer to the 20th
  century, and years from 0 to 56 to the 21st century.
- `epoch_day::Float64`: Epoch day (day + fraction of the day), in the interval [0, 367).
- `dn_o2::Float64`: 1st time derivative of mean motion / 2 [rev/day²].
- `ddn_o6::Float64`: 2nd time derivative of mean motion / 6 [rev/day³].
- `bstar::Float64`: B* drag term [1/ER].
- `ephemeris_type::Int`: Ephemeris type (one digit).
- `element_set_number::Int`: Element set number, in the interval [0, 9999].
- `inclination::Float64`: Inclination [deg].
- `raan::Float64`: Right ascension of the ascending node [deg].
- `eccentricity::Float64`: Eccentricity [ ], in the interval [0, 1).
- `argument_of_perigee::Float64`: Argument of perigee [deg].
- `mean_anomaly::Float64`: Mean anomaly [deg].
- `mean_motion::Float64`: Mean motion [rev/day], in the interval [0, 100).
- `revolution_number::Int`: Revolution number at epoch [rev], in the interval [0, 99999].

Notice that we preserve the units of the TLE definition. The constructor validates that
every field can be represented in the fixed-width TLE format, throwing an `ArgumentError`
otherwise. Hence, writing a `TLE` never fails.

Besides the fields, the property `epoch` returns the TLE epoch as a `DateTime`:

```@repl tle_structure
using SatelliteToolboxTle

tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

tle.epoch
```
