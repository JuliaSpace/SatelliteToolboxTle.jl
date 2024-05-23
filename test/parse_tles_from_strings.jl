## Description #############################################################################
#
# Tests related to TLE parsing from strings.
#
############################################################################################

# == Function: read_tle ====================================================================

@testset "Function: read_tle (Individual Lines)" begin
    # == Default ===========================================================================

    l1 = "       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990"
    l2 = " 2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652"

    tle = read_tle(l1, l2; name = "AMAZONIA 1")

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

    # == No Checksum Verification ==========================================================

    l1 = "       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999"
    l2 = " 2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659"

    tle = read_tle(l1, l2; name = "AMAZONIA 1", verify_checksum = false)

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

@testset "Function read_tle (Individual Lines) [ERRORS]" begin
    # == Checksum Error ====================================================================

    l1 = "       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9991"
    l2 = " 2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652"

    @test_throws ArgumentError read_tle(l1, l2)
    @test_logs (
        :error,
        "Wrong checksum in TLE line 1 (expected = 0, found = 1)."
    ) try read_tle(l1, l2) catch end

    l1 = "       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990"
    l2 = " 2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108655"

    @test_throws ArgumentError read_tle(l1, l2)
    @test_logs (
        :error,
        "Wrong checksum in TLE line 2 (expected = 2, found = 5)."
    ) try read_tle(l1, l2) catch end

    # == Invalid Lines =====================================================================

    l1 = "       2 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990"
    l2 = " 2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108655"

    @test_throws ArgumentError read_tle(l1, l2)
    @test_logs (
        :error,
        "The 1st line is not valid."
    ) try read_tle(l1, l2) catch end

    l1 = "       1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990"
    l2 = " 3 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652"

    @test_throws ArgumentError read_tle(l1, l2)
    @test_logs (
        :error,
        "The 2nd line is not valid."
    ) try read_tle(l1, l2) catch end

end

@testset "Function: read_tle (string)" begin
    # == Default (Two Lines) ===============================================================

    tle_str = """
        # This line should be ignored
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    tle = read_tle(tle_str)

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

    # == Default (Three Lines) =============================================================

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    tle = read_tle(tle_str)

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

    # == No Checksum Verification ==========================================================

    tle_str = """
        # This line should be ignored
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659
        """

    tle = read_tle(tle_str; verify_checksum = false)

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

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659
        """

    tle = read_tle(tle_str; verify_checksum = false)

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

@testset "Function read_tle (string) [ERRORS]" begin

    # == Checksum Error ====================================================================

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9991
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    @test_throws ArgumentError read_tle(tle_str)
    @test_logs (
        :error,
        "Wrong checksum in TLE line 1 (expected = 0, found = 1)."
    ) try read_tle(tle_str) catch end

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108653
        """

    @test_throws ArgumentError read_tle(tle_str)
    @test_logs (
        :error,
        "Wrong checksum in TLE line 2 (expected = 2, found = 3)."
    ) try read_tle(tle_str) catch end

    # == Error Related With the Number of Lines ============================================

    tle_str = """
        # This line should be ignored
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
        """

    @test_throws ArgumentError read_tle(tle_str)

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108653
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108653
        """

    @test_throws ArgumentError read_tle(tle_str)

    # == Invalid Lines =====================================================================

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          2 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    @test_throws ArgumentError read_tle(tle_str)
    @test_logs (
        :error,
        "The 1st line is not valid."
    ) try read_tle(tle_str) catch end

    tle_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
                3 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
        """

    @test_throws ArgumentError read_tle(tle_str)
    @test_logs (
        :error,
        "The 2nd line is not valid."
    ) try read_tle(tle_str) catch end
end

# == Function: read_tles ===================================================================

@testset "Function: read_tles" begin
    # == Default ===========================================================================

    tles_str = """
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

    tles = read_tles(tles_str)

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

    # == No Checksum Verification ==========================================================

    tles_str = """
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

    tles = read_tles(tles_str; verify_checksum = false)

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

    # == No Satellite Name =================================================================

    tles_str = """
        # This line should be ignored
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108659
            # Another comment
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9999
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176409
        """

    tles = read_tles(tles_str; verify_checksum = false)

    @test length(tles) == 2

    amz1_tle = tles |> first

    @test amz1_tle.name                     == "UNDEFINED"
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

    @test cbers_tle.name                     == "UNDEFINED"
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

@testset "Function read_tles [ERRORS]" begin

    # == Checksum Error ====================================================================

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9999
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    tles = read_tles(tles_str)
    @test length(tles) == 1
    tle = tles |> first
    @test tle.name == "AMAZONIA 1"

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    tles = read_tles(tles_str)
    @test length(tles) == 1
    tle = tles |> first
    @test tle.name =="CBERS 4A"

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9999
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9999
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    tles = read_tles(tles_str)
    @test length(tles) == 0

    # == Field Errors ======================================================================

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  99990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: This is not a valid 1st line."
    ) read_tles(tles_str)
    @test length(read_tles(tles_str)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.4081439410865 2
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: This is not a valid 2nd line."
    ) read_tles(tles_str)
    @test length(read_tles(tles_str)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 A7699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The satellite number in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   2A083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The epoch year in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.686A7856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The epoch day in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.0000004A  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The first derivative of mean motion (dn_o2) in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  100G0-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The second derivative of mean motion (ddn_o6) in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-A  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The second derivative of mean motion (ddn_o6) in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  430C0-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The BSTAR in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 1  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :warn,
        "[Line 3]: TLE ephemeris type should be 0."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 2

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  99A0
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 3]: The element set number in the TLE line 1 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 A7699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The satellite number in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47698  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: Satellite number in line 2 is not equal to that in line 1."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.43B4 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The inclination in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1A97 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The rigth ascension of the ascending node (RAAN) in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 00B1247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The eccentricity in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136X2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The argument of perigee in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.928C 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The mean anomaly in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40N14394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The mean motion in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108H52
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
            2 44883  97.8666 164.4776 0001781  94.0485 266.0964 14.81596492176403
        """

    @test_logs (
        :error,
        "[Line 5]: The revolution number in the TLE line 2 could not be parsed."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1

    # == Incomplete TLEs ===================================================================

    tles_str = """
        # This line should be ignored
             AMAZONIA 1
          1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
        # This is a comment.
            2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
            # Another comment
        CBERS 4A
            1 44883U 19093E   23084.50188177  .00004132  00000+0  53225-3 0  9992
        """

    @test_logs (
        :error,
        "[Line 8]: The last TLE in the file is incomplete."
    ) read_tles(tles_str; verify_checksum = false)
    @test length(read_tles(tles_str; verify_checksum = false)) == 1
end
