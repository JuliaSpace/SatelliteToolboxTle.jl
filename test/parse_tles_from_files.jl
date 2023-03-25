# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to TLE parsing from files.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Function read_tles_from_file
# ==============================================================================

@testset "Function read_tles_from_file" begin
    # Default
    # ==========================================================================

    tles = read_tles_from_file("samples.tle")

    @test length(tles) == 2

    amz1_tle = tles |> first

    @test amz1_tle.name                     == "AMAZONIA 1"
    @test amz1_tle.satellite_number         == 47699
    @test amz1_tle.classification           == 'U'
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.epoch_year               == 23
    @test amz1_tle.epoch_day                == 83.68657856
    @test amz1_tle.dn_o2                    == -4.4e-7
    @test amz1_tle.ddn_o6                   == 1.0e-9
    @test amz1_tle.bstar                    == 4.3e-5
    @test amz1_tle.element_set_number       == 999
    @test amz1_tle.inclination              == 98.4304
    @test amz1_tle.raan                     == 162.1097
    @test amz1_tle.eccentricity             == 0.0001247
    @test amz1_tle.argument_of_perigee      == 136.2017
    @test amz1_tle.mean_anomaly             == 223.9283
    @test amz1_tle.mean_motion              == 14.40814394
    @test amz1_tle.revolution_number        == 10865

    cbers_tle = tles |> last

    @test cbers_tle.name                     == "CBERS 4A"
    @test cbers_tle.satellite_number         == 44883
    @test cbers_tle.classification           == 'U'
    @test cbers_tle.international_designator == "19093E"
    @test cbers_tle.epoch_year               == 23
    @test cbers_tle.epoch_day                == 84.50188177
    @test cbers_tle.dn_o2                    == 4.132e-5
    @test cbers_tle.ddn_o6                   == 0.0
    @test cbers_tle.bstar                    ≈  0.53225e-3
    @test cbers_tle.element_set_number       == 999
    @test cbers_tle.inclination              == 97.8666
    @test cbers_tle.raan                     == 164.4776
    @test cbers_tle.eccentricity             == 0.0001781
    @test cbers_tle.argument_of_perigee      == 94.0485
    @test cbers_tle.mean_anomaly             == 266.0964
    @test cbers_tle.mean_motion              == 14.81596492
    @test cbers_tle.revolution_number        == 17640

    # No checksum verification
    # ==========================================================================

    tles = read_tles_from_file("samples-wrong_checksum.tle"; verify_checksum = false)

    @test length(tles) == 2

    amz1_tle = tles |> first

    @test amz1_tle.name                     == "AMAZONIA 1"
    @test amz1_tle.satellite_number         == 47699
    @test amz1_tle.classification           == 'U'
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.epoch_year               == 23
    @test amz1_tle.epoch_day                == 83.68657856
    @test amz1_tle.dn_o2                    == -4.4e-7
    @test amz1_tle.ddn_o6                   == 1.0e-9
    @test amz1_tle.bstar                    == 4.3e-5
    @test amz1_tle.element_set_number       == 999
    @test amz1_tle.inclination              == 98.4304
    @test amz1_tle.raan                     == 162.1097
    @test amz1_tle.eccentricity             == 0.0001247
    @test amz1_tle.argument_of_perigee      == 136.2017
    @test amz1_tle.mean_anomaly             == 223.9283
    @test amz1_tle.mean_motion              == 14.40814394
    @test amz1_tle.revolution_number        == 10865

    cbers_tle = tles |> last

    @test cbers_tle.name                     == "CBERS 4A"
    @test cbers_tle.satellite_number         == 44883
    @test cbers_tle.classification           == 'U'
    @test cbers_tle.international_designator == "19093E"
    @test cbers_tle.epoch_year               == 23
    @test cbers_tle.epoch_day                == 84.50188177
    @test cbers_tle.dn_o2                    == 4.132e-5
    @test cbers_tle.ddn_o6                   == 0.0
    @test cbers_tle.bstar                    ≈  0.53225e-3
    @test cbers_tle.element_set_number       == 999
    @test cbers_tle.inclination              == 97.8666
    @test cbers_tle.raan                     == 164.4776
    @test cbers_tle.eccentricity             == 0.0001781
    @test cbers_tle.argument_of_perigee      == 94.0485
    @test cbers_tle.mean_anomaly             == 266.0964
    @test cbers_tle.mean_motion              == 14.81596492
    @test cbers_tle.revolution_number        == 17640
end

@testset "Function read_tles_from_file [ERRORS]" begin
    # Checksum
    # ==========================================================================

    tles = read_tles_from_file("samples-wrong_checksum.tle")

    @test length(tles) == 1

    cbers_tle = tles |> last

    @test cbers_tle.name                     == "CBERS 4A"
    @test cbers_tle.satellite_number         == 44883
    @test cbers_tle.classification           == 'U'
    @test cbers_tle.international_designator == "19093E"
    @test cbers_tle.epoch_year               == 23
    @test cbers_tle.epoch_day                == 84.50188177
    @test cbers_tle.dn_o2                    == 4.132e-5
    @test cbers_tle.ddn_o6                   == 0.0
    @test cbers_tle.bstar                    ≈  0.53225e-3
    @test cbers_tle.element_set_number       == 999
    @test cbers_tle.inclination              == 97.8666
    @test cbers_tle.raan                     == 164.4776
    @test cbers_tle.eccentricity             == 0.0001781
    @test cbers_tle.argument_of_perigee      == 94.0485
    @test cbers_tle.mean_anomaly             == 266.0964
    @test cbers_tle.mean_motion              == 14.81596492
    @test cbers_tle.revolution_number        == 17640

    @test_logs (
        :error,
        "[Line 3]: Wrong checksum in TLE line 1 (expected = 0, found = 3)."
    ) read_tles_from_file("samples-wrong_checksum.tle")
end
