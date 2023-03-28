Creating TLEs
=============

```@meta
CurrentModule = SatelliteToolboxTle
DocTestSetup = quote
    using SatelliteToolboxTle
end
```

We can create a TLE using the function:

```julia
TLE(; kwargs...)
```

where `kwargs...` are keywords arguments with the same name as in the TLE
fields, as explained [here](@ref tle_structure). The following elements are
required:

- `epoch_year`, `epoch_day`, `inclination`, `raan`, `eccentricity`,
    `argument_of_perigee`, `mean_anomaly` and `mean_motion`.

The algorithm assigns default values for the other fields if they are not
present.
    
```jldoctest
julia> tle = TLE(
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
TLE:
                     Name : My satellite
         Satellite number : 0
 International designator : 00000
       Epoch (Year / Day) : 23 /   1.50000000 (2023-01-01T12:00:00)
       Element set number : 0
             Eccentricity :   0.00100000 deg
              Inclination :  98.40500000 deg
                     RAAN : 220.19000000 deg
      Argument of perigee :  90.00000000 deg
             Mean anomaly :   0.00000000 deg
          Mean motion (n) :  14.40000000 revs/day
        Revolution number : 0
                       B* : 0.000000 1/[er]
                    ṅ / 2 : 0.000000 rev/day²
                    n̈ / 6 : 0.000000 rev/day³
```
