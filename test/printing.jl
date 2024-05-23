## Description #############################################################################
#
# Tests related to how TLEs are printed.
#
############################################################################################

# == Function: print =======================================================================

@testset "Function print" begin
    tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

    expected = "TLE: AMAZONIA 1 (Epoch = 2023-03-24T16:28:40.388)"
    str = sprint(print, tle)

    @test str == expected
end

# == Function: show ========================================================================

@testset "Function show" begin
    tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

    # == Without Colors ====================================================================

    expected = """
    TLE:
                          Name : AMAZONIA 1
              Satellite number : 47699
      International designator : 21015A
            Epoch (Year / Day) : 23 /  83.68657856 (2023-03-24T16:28:40.388)
            Element set number : 999
                  Eccentricity :   0.00012470
                   Inclination :  98.43040000 deg
                          RAAN : 162.10970000 deg
           Argument of perigee : 136.20170000 deg
                  Mean anomaly : 223.92830000 deg
               Mean motion (n) :  14.40814394 revs / day
             Revolution number : 10865
                            B* :      4.3e-05 1 / er
                         ṅ / 2 :     -4.4e-07 rev / day²
                         n̈ / 6 :        1e-09 rev / day³"""

    buf = IOBuffer()
    show(buf, MIME("text/plain"), tle)
    str = String(take!(buf))

    @test str == expected

    # == With Colors =======================================================================

    expected = """
    TLE:
    \e[1m                      Name : \e[0mAMAZONIA 1
    \e[1m          Satellite number : \e[0m47699
    \e[1m  International designator : \e[0m21015A
    \e[1m        Epoch (Year / Day) : \e[0m23 /  83.68657856 (2023-03-24T16:28:40.388)
    \e[1m        Element set number : \e[0m999
    \e[1m              Eccentricity : \e[0m  0.00012470
    \e[1m               Inclination : \e[0m 98.43040000 deg
    \e[1m                      RAAN : \e[0m162.10970000 deg
    \e[1m       Argument of perigee : \e[0m136.20170000 deg
    \e[1m              Mean anomaly : \e[0m223.92830000 deg
    \e[1m           Mean motion (n) : \e[0m 14.40814394 revs / day
    \e[1m         Revolution number : \e[0m10865
    \e[1m                        B* : \e[0m     4.3e-05 1 / er
    \e[1m                     ṅ / 2 : \e[0m    -4.4e-07 rev / day²
    \e[1m                     n̈ / 6 : \e[0m       1e-09 rev / day³"""

    buf = IOBuffer()
    io = IOContext(buf, :color => true)
    show(io, MIME("text/plain"), tle)
    str = String(take!(buf))

    @test str == expected
end
