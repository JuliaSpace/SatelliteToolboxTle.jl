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

- `epoch_year`, `epoch_day`, `inclination`, `raan`, `eccentricity`, `argument_of_perigee`,
    `mean_anomaly` and `mean_motion`.

The algorithm assigns default values for the other fields if they are not present.

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
```

The text representation of the TLE can be obtained by converting the object to a string
using `convert`:

```@repl creating_tles
convert(String, tle) |> print
```
