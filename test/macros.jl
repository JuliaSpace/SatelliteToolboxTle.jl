# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to test the macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Macros: @tle_str and @tle_nc_str
# ==============================================================================

@testset "Macros @tle_str and @tle_nc_str" begin

    # Default (two lines)
    # ==========================================================================

    tle = tle"""
        # This line should be ignored
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    @test tle.name                     == "UNDEFINED"
    @test tle.satellite_number         == 47699
    @test tle.classification           == 'U'
    @test tle.international_designator == "21015A"
    @test tle.epoch_year               == 23
    @test tle.epoch_day                == 83.68657856
    @test tle.dn_o2                    == -4.4e-7
    @test tle.ddn_o6                   == 1.0e-9
    @test tle.bstar                    == 4.3e-5
    @test tle.element_set_number       == 999
    @test tle.inclination              == 98.4304
    @test tle.raan                     == 162.1097
    @test tle.eccentricity             == 0.0001247
    @test tle.argument_of_perigee      == 136.2017
    @test tle.mean_anomaly             == 223.9283
    @test tle.mean_motion              == 14.40814394
    @test tle.revolution_number        == 10865

    # Default (three lines)
    # ==========================================================================

    tle = tle"""
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    @test tle.name                     == "AMAZONIA 1"
    @test tle.satellite_number         == 47699
    @test tle.classification           == 'U'
    @test tle.international_designator == "21015A"
    @test tle.epoch_year               == 23
    @test tle.epoch_day                == 83.68657856
    @test tle.dn_o2                    == -4.4e-7
    @test tle.ddn_o6                   == 1.0e-9
    @test tle.bstar                    == 4.3e-5
    @test tle.element_set_number       == 999
    @test tle.inclination              == 98.4304
    @test tle.raan                     == 162.1097
    @test tle.eccentricity             == 0.0001247
    @test tle.argument_of_perigee      == 136.2017
    @test tle.mean_anomaly             == 223.9283
    @test tle.mean_motion              == 14.40814394
    @test tle.revolution_number        == 10865

    # No checksum verification
    # ==========================================================================

    tle = tle_nc"""
        # This line should be ignored
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659
        """

    @test tle.name                     == "UNDEFINED"
    @test tle.satellite_number         == 47699
    @test tle.classification           == 'U'
    @test tle.international_designator == "21015A"
    @test tle.epoch_year               == 23
    @test tle.epoch_day                == 83.68657856
    @test tle.dn_o2                    == -4.4e-7
    @test tle.ddn_o6                   == 1.0e-9
    @test tle.bstar                    == 4.3e-5
    @test tle.element_set_number       == 999
    @test tle.inclination              == 98.4304
    @test tle.raan                     == 162.1097
    @test tle.eccentricity             == 0.0001247
    @test tle.argument_of_perigee      == 136.2017
    @test tle.mean_anomaly             == 223.9283
    @test tle.mean_motion              == 14.40814394
    @test tle.revolution_number        == 10865

    tle = tle_nc"""
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659
        """

    @test tle.name                     == "AMAZONIA 1"
    @test tle.satellite_number         == 47699
    @test tle.classification           == 'U'
    @test tle.international_designator == "21015A"
    @test tle.epoch_year               == 23
    @test tle.epoch_day                == 83.68657856
    @test tle.dn_o2                    == -4.4e-7
    @test tle.ddn_o6                   == 1.0e-9
    @test tle.bstar                    == 4.3e-5
    @test tle.element_set_number       == 999
    @test tle.inclination              == 98.4304
    @test tle.raan                     == 162.1097
    @test tle.eccentricity             == 0.0001247
    @test tle.argument_of_perigee      == 136.2017
    @test tle.mean_anomaly             == 223.9283
    @test tle.mean_motion              == 14.40814394
    @test tle.revolution_number        == 10865
end

# Macros: @tles_str and @tles_nc_str
# ==============================================================================

@testset "Macros @tles_str and @tles_nc_str" begin

    # Default
    # ==========================================================================

    tles = tles"""
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

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

    tles = tles_nc"""
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9999
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176409
        """

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
