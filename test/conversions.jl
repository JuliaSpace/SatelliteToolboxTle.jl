## Description #############################################################################
#
# Test conversions related to TLEs.
#
############################################################################################

# == Conversion to String ==================================================================

@testset "Conversion TLE => String" begin
    tles = read_tles_from_file("./tles_20200122.tle")
    f    = open("./tles_20200122.tle", "r")

    for i in 1:length(tles)
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
            stri_l1 = stri_l1[1:50] * "+" * stri_l1[52:(end - 1)]
            stri_l1 *= string(tle_line_checksum(stri_l1[1:end]))
        end

        if (tles[i].bstar == 0) && (stri_l1[60] == '-')
            stri_l1 = stri_l1[1:59] * "+" * stri_l1[61:(end - 1)]
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
    tle = TLE(;
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

@testset "Conversion TLE => String, Epoch Year With One Digit" begin
    tle = TLE(;
        name                     = "Amazonia-1",
        satellite_number         = 47699,
        classification           = 'U',
        international_designator = "21015A",
        epoch_year               = 6,
        epoch_day                = 83.68657856,
        dn_o2                    = -0.00000044,
        ddn_o6                   = 0.00000001,
        bstar                    = 0.000043,
        element_set_number       = 999,
        inclination              = 98.4304,
        raan                     = 162.1097,
        eccentricity             = 0.0001247,
        argument_of_perigee      = 136.2017,
        mean_anomaly             = 223.9283,
        mean_motion              = 14.40814394,
        revolution_number        = 10865,
    )

    str = convert(String, tle)

    # The epoch year must be zero-padded to two digits.
    l1 = split(str, '\n')[2]
    @test l1[19:20] == "06"
    @test length(l1) == 69

    # The generated TLE must be parsable, recovering the same epoch year.
    @test read_tle(str).epoch_year == 6
end

@testset "Conversion TLE => String, Rounding Overflows" begin
    # All the values below round to 1 (or to the next integer) at the printed precision.
    # Hence, without the proper treatment, the fields would silently lose their integer
    # part or carry.
    tle = TLE(;
        satellite_number         = 47699,
        international_designator = "21015A",
        epoch_year               = 23,
        epoch_day                = 83.999999996,
        ddn_o6                   = 0.099999996,
        bstar                    = 0.099999996,
        element_set_number       = 999,
        inclination              = 98.4304,
        raan                     = 162.1097,
        eccentricity             = 0.99999996,
        argument_of_perigee      = 136.2017,
        mean_anomaly             = 223.9283,
        mean_motion              = 14.40814394,
        revolution_number        = 10865,
    )

    parsed = convert(String, tle) |> read_tle

    @test parsed.epoch_day == 84.0
    @test parsed.ddn_o6 == 0.1
    @test parsed.bstar == 0.1
    @test parsed.eccentricity == 0.9999999

    # The dn_o2 field must saturate when its magnitude reaches 1 after the rounding.
    tle = TLE(;
        satellite_number         = 47699,
        international_designator = "21015A",
        epoch_year               = 23,
        epoch_day                = 83.68657856,
        dn_o2                    = 0.999999996,
        element_set_number       = 999,
        inclination              = 98.4304,
        raan                     = 162.1097,
        eccentricity             = 0.0001247,
        argument_of_perigee      = 136.2017,
        mean_anomaly             = 223.9283,
        mean_motion              = 14.40814394,
        revolution_number        = 10865,
    )

    str = @test_logs (
        :warn,
        "The dn_o2 magnitude cannot be represented in a TLE. The field will be saturated.",
    ) convert(String, tle)

    @test read_tle(str).dn_o2 == 0.99999999
end

@testset "Conversion TLE => String, Exponents Outside the TLE Range" begin
    tle = TLE(;
        satellite_number         = 47699,
        international_designator = "21015A",
        epoch_year               = 23,
        epoch_day                = 83.68657856,
        ddn_o6                   = 1e11,
        bstar                    = 1e-13,
        element_set_number       = 999,
        inclination              = 98.4304,
        raan                     = 162.1097,
        eccentricity             = 0.0001247,
        argument_of_perigee      = 136.2017,
        mean_anomaly             = 223.9283,
        mean_motion              = 14.40814394,
        revolution_number        = 10865,
    )

    # The ddn_o6 exponent is larger than 9. Hence, the field must be saturated. The bstar
    # exponent is lower than -9, but the value can still be represented by denormalizing
    # the mantissa.
    str = @test_logs (
        :warn,
        "The ddn_o6 magnitude is too large to be represented in a TLE. The field will " *
        "be saturated.",
    ) convert(String, tle)

    parsed = read_tle(str)

    @test parsed.ddn_o6 == 9.9999e8
    @test parsed.bstar ≈ 1e-13

    # If the value is too small to be represented even with a denormalized mantissa, the
    # field must be set to 0.
    tle = TLE(;
        satellite_number         = 47699,
        international_designator = "21015A",
        epoch_year               = 23,
        epoch_day                = 83.68657856,
        bstar                    = 1e-16,
        element_set_number       = 999,
        inclination              = 98.4304,
        raan                     = 162.1097,
        eccentricity             = 0.0001247,
        argument_of_perigee      = 136.2017,
        mean_anomaly             = 223.9283,
        mean_motion              = 14.40814394,
        revolution_number        = 10865,
    )

    str = @test_logs (
        :warn,
        "The BSTAR magnitude is too small to be represented in a TLE. The field will " *
        "be set to 0.",
    ) convert(String, tle)

    @test read_tle(str).bstar == 0
end

# == Function: tle_epoch ===================================================================

@testset "Function: tle_epoch" begin
    tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

    expected_epoch_dt = DateTime(2023, 3, 24, 16, 28, 40, 388)

    @test tle_epoch(tle) ≈ datetime2julian(expected_epoch_dt)
    @test tle_epoch(DateTime, tle) == expected_epoch_dt
end
