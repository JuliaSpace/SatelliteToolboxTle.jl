Creating TLEs
=============

```@meta
CurrentModule = SatelliteToolboxTle
```

```@setup creating_tles
using SatelliteToolboxTle
```

We can create a TLE using the function:

```julia
TLE(; kwargs...)
```

where `kwargs...` are keywords arguments with the same name as in the TLE fields, as
explained [here](@ref tle_structure). The following elements are required:

- `inclination`, `raan`, `eccentricity`, `argument_of_perigee`, `mean_anomaly`, and
    `mean_motion`.

The epoch must be provided either by the keywords `epoch_year` and `epoch_day`, or by the
keyword `epoch` with a `DateTime`, from which the former are computed. The algorithm assigns
default values for the other fields if they are not present.

```@repl creating_tles
tle = TLE(
    name = "My satellite",
    epoch_year = 23,
    epoch_day = 1.5,
    inclination = 98.405,
    raan = 220.19,
    eccentricity = 0.001,
    argument_of_perigee = 90,
    mean_anomaly = 0.0,
    mean_motion = 14.4
)

using Dates

tle = TLE(
    name = "My satellite",
    epoch = DateTime(2023, 1, 1, 12),
    inclination = 98.405,
    raan = 220.19,
    eccentricity = 0.001,
    argument_of_perigee = 90,
    mean_anomaly = 0.0,
    mean_motion = 14.4
)
```

The constructor validates that every field can be represented in the TLE format. For
example, an eccentricity outside the interval [0, 1) or a satellite number above 339999
throws an `ArgumentError`:

```@repl creating_tles
TLE(
    epoch_year = 23,
    epoch_day = 1.5,
    inclination = 98.405,
    raan = 220.19,
    eccentricity = 1.2,
    argument_of_perigee = 90,
    mean_anomaly = 0.0,
    mean_motion = 14.4
)
```

## Writing TLEs

The functions [`write_tle`](@ref) and [`write_tles`](@ref) write one or multiple TLEs to a
stream or to a file:

```@repl creating_tles
write_tle(stdout, tle)

write_tles(stdout, [tle, tle])
```

If the first argument is the type `String`, the text representation is returned instead:

```@repl creating_tles
write_tle(String, tle)
```

The angles are normalized to the interval [0, 360)° before being written. If the magnitude
of `dn_o2`, `ddn_o6`, or `bstar` cannot be represented in its TLE field, the field is
saturated and a warning is emitted.
