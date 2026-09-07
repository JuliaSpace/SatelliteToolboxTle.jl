## Description #############################################################################
#
# Precompilation.
#
############################################################################################

import PrecompileTools

PrecompileTools.@compile_workload begin
    # == Parsing and Reading ===============================================================

    # Parse one TLE with the satellite name using the string macro.
    tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

    # Parse a set of TLEs, exercising the multi-TLE reader.
    tles = tles"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    CBERS 4A
    1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
    2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
    """

    # Parse the TLE from its two lines.
    l1  = "1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990"
    l2  = "2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652"
    tle = read_tle(l1, l2; name = "AMAZONIA 1")

    # Exercise the error path of the parser using a line with a wrong checksum.
    try
        read_tle(l1, l2[1:68] * "3")
    catch e
        e isa TleParseError || rethrow(e)
    end

    # == Creation ==========================================================================

    # Create a TLE using the keyword constructor with the epoch as a `DateTime`.
    TLE(;
        epoch               = DateTime(2023, 3, 24, 16, 28, 40, 388),
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    # == Conversion and Writing ============================================================

    write_tle(String, tle)
    write_tles(IOBuffer(), tles)
    tle_epoch(tle)
    tle_epoch(DateTime, tle)

    # == Show ==============================================================================

    show(IOBuffer(), tle)
    show(IOBuffer(), MIME("text/plain"), tle)
    show(IOContext(IOBuffer(), :color => true), MIME("text/plain"), tle)
end
