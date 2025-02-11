## Description #############################################################################
#
# Functions to test the errors when creating and converting TLEs.
#
############################################################################################

@testset "Errors When Creating TLEs" begin
    @test_throws ArgumentError TLE(
        ;
        satellite_number    = -1,
        epoch_year          = 23,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    @test_throws ArgumentError TLE(
        ;
        epoch_year          = 23,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 1.01,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    @test_throws ArgumentError TLE(
        ;
        epoch_year          = 23,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = -0.01,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    @test_throws ArgumentError TLE(
        ;
        epoch_year          = -1,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    @test_throws ArgumentError TLE(
        ;
        epoch_year          = 23,
        epoch_day           = -0.1,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    @test_throws ArgumentError TLE(
        ;
        element_set_number  = -1,
        epoch_year          = 23,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    @test_throws ArgumentError TLE(
        ;
        revolution_number   = -1,
        epoch_year          = 23,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )
end
