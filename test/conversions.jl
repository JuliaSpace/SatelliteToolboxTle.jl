## Description #############################################################################
#
# Test conversions related to TLEs.
#
############################################################################################

# == Conversion to String ==================================================================

@testset "Conversion TLE => String" begin
    tles = read_tles_from_file("./tles_20200122.tle")
    f    = open("./tles_20200122.tle", "r")

    for i = 1:length(tles)
        stri_name = readline(f)
        stri_l1   = readline(f)
        stri_l2   = readline(f)

        # The TLE for AMOS-4 has a `-` before the first time derivative, even though it is
        # 0. Since this is happening only here, we will skip this case.
        tles[i].satellite_number == 39237 && continue

        # The conversion of the exponent signal of the second derivative of the mean motion
        # and BSTAR does not have a defined pattern if they are 0. We will always using '+'.
        # Hence, if the current TLE uses `-`, we need to change it and update the checksum.

        if (tles[i].ddn_o6 == 0) && (stri_l1[51] == '-')
            stri_l1  = stri_l1[1:50] * "+" * stri_l1[52:end-1]
            stri_l1 *= string(tle_line_checksum(stri_l1[1:end]))
        end

        if (tles[i].bstar == 0) && (stri_l1[60] == '-')
            stri_l1 = stri_l1[1:59] * "+" * stri_l1[61:end-1]
            stri_l1 *= string(tle_line_checksum(stri_l1[1:end]))
        end

        stri = stri_name * "\n" * stri_l1 * "\n" * stri_l2

        # If the OS is Windows, we should remove `\r` to avoid testing failure.
        Sys.iswindows() && (stri = replace(stri, "\r" => ""))

        strf = convert(String, tles[i])

        @test strf == stri
    end
end

@testset "Conversion TLE => String, Corner Cases" begin
    tle = TLE(
        ;
        name                     = "Amazonia-1",
        satellite_number         = 47699,
        classification           = 'U',
        international_designator = "21015A",
        epoch_year               = 23,
        epoch_day                = 83.68657856,
        dn_o2                    = -0.00000044,
        ddn_o6                   = 0.00000001,
        bstar                    = 0.000043,
        element_set_number       = 999,
        inclination              = (98.4304 - 360),
        raan                     = (162.1097 - 360),
        eccentricity             = 0.0001247,
        argument_of_perigee      = (136.2017 - 360),
        mean_anomaly             = (223.9283 - 360),
        mean_motion              = 14.40814394,
        revolution_number        = 10865,
    )

    str = convert(String, tle)

    println(str)

    expected_str = """
        Amazonia-1              
        1 47699U 21015A   23083.68657856 -.00000044  10000-7  43000-4 0  9999
        2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652"""

    @test str == expected_str
end

# == Function: tle_epoch ===================================================================

@testset "Function: tle_epoch" begin
    tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

    expected_epoch_dt = DateTime(2023, 3, 24, 16, 28, 40, 388)

    @test tle_epoch(tle)            ≈ datetime2julian(expected_epoch_dt)
    @test tle_epoch(DateTime, tle) == expected_epoch_dt
end
