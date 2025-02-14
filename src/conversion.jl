## Description #############################################################################
#
# Functions to perform conversions between TLE and other types.
#
############################################################################################

export tle_epoch

############################################################################################
#                                        Overloads                                         #
############################################################################################

function convert(::Type{String}, tle::TLE)
    # == Unpack Fields =====================================================================

    name                     = tle.name

    satellite_number         = tle.satellite_number
    classification           = tle.classification
    international_designator = tle.international_designator
    epoch_year               = tle.epoch_year
    epoch_day                = tle.epoch_day
    dn_o2                    = tle.dn_o2
    ddn_o6                   = tle.ddn_o6
    bstar                    = tle.bstar

    element_set_number       = tle.element_set_number
    inclination              = mod(tle.inclination, 360)
    raan                     = mod(tle.raan, 360)
    eccentricity             = tle.eccentricity
    argument_of_perigee      = mod(tle.argument_of_perigee, 360)
    mean_anomaly             = mod(tle.mean_anomaly, 360)
    mean_motion              = tle.mean_motion
    revolution_number        = tle.revolution_number

    # == Name ==============================================================================

    str_name = @sprintf("%-24s", name)

    # == First Line ========================================================================

    buf = IOBuffer()

    # -- Line ID ---------------------------------------------------------------------------

    print(buf, "1 ")

    # -- Satellite Number and Classification -----------------------------------------------

    str_sat_num = @sprintf("%05d", satellite_number)[1:5]
    print(buf, str_sat_num)
    print(buf, classification, " ")

    # -- International Designator ----------------------------------------------------------

    if length(international_designator) >= 8
        print(buf, international_designator[1:8], " ")
    else
        print(buf, rpad(international_designator, 8), " ")
    end

    # -- Epoch (Year) ----------------------------------------------------------------------

    print(buf, @sprintf("%-2d", epoch_year)[1:2])

    # -- Epoch (Day + Fraction of the Day) -------------------------------------------------

    i_epoch_day = floor(Int,epoch_day)
    f_epoch_day = epoch_day - i_epoch_day

    print(
        buf,
        @sprintf("%03d", i_epoch_day)[1:3],
        ".",
        @sprintf("%-10.8f", f_epoch_day)[3:10],
        " "
    )

    # -- First Time Derivative of the Mean Motion ------------------------------------------

    print(
        buf,
        dn_o2 < 0 ? "-." : " .",
        @sprintf("%-10.8f", abs(dn_o2))[3:10],
        " "
    )

    # -- Second Time Derivative of the Mean Motion -----------------------------------------

    mant, exp = _get_mant_exp(abs(ddn_o6))

    print(
        buf,
        ddn_o6 < 0 ? "-" : " ",
        @sprintf("%-7.5f", mant)[3:7],
        exp >= 0 ? "+" : "-",
        @sprintf("%-2d", abs(exp))[1],
        " "
    )

    # -- BSTAR -----------------------------------------------------------------------------

    mant, exp = _get_mant_exp(abs(bstar))

    print(
        buf,
        bstar < 0 ? "-" : " ",
        @sprintf("%-7.5f", mant)[3:7],
        exp < 0 ? "-" : "+",
        @sprintf("%-2d", abs(exp))[1],
        " "
    )

    # -- Ephemeris Type --------------------------------------------------------------------

    print(buf, "0 ")

    # -- Element Number --------------------------------------------------------------------

    print(buf, @sprintf("%4d", element_set_number)[1:4])

    # -- Checksum --------------------------------------------------------------------------

    str_l1  = String(take!(buf))
    str_l1 *= string(tle_line_checksum(str_l1))[1]

    # == Second Line =======================================================================

    # -- ID --------------------------------------------------------------------------------

    print(buf, "2 ")

    # -- Satellite Number ------------------------------------------------------------------

    print(buf, str_sat_num, " ")

    # -- Inclination [°] -------------------------------------------------------------------

    print(buf, @sprintf("%8.4f", inclination), " ")

    # -- Right Ascension of the Ascending Node [°] -----------------------------------------

    print(buf, @sprintf("%8.4f", raan), " ")

    # -- Eccentricity [°] ------------------------------------------------------------------

    print(buf, @sprintf("%-9.7f", eccentricity)[3:9], " ")

    # -- Argument of Perigee [°] -----------------------------------------------------------

    print(buf, @sprintf("%8.4f", argument_of_perigee), " ")

    # -- Mean Anomaly [°] ------------------------------------------------------------------

    print(buf, @sprintf("%8.4f", mean_anomaly), " ")

    # -- Mean Motion [rev/day] -------------------------------------------------------------

    print(buf, @sprintf("%11.8f", mean_motion))

    # -- Revolution Number at Epoch [revs] -------------------------------------------------

    print(buf, @sprintf("%5d", revolution_number)[1:5])

    # -- Checksum --------------------------------------------------------------------------

    str_l2  = String(take!(buf))
    str_l2 *= string(tle_line_checksum(str_l2))[1]

    # == Assemble and Return the TLE =======================================================

    return str_name * '\n' * str_l1 * '\n' * str_l2
end

############################################################################################
#                                     Public Functions                                     #
############################################################################################

"""
    tle_epoch(tle::TLE) -> Float64

Return the Julian day related to the `tle` epoch.
"""
function tle_epoch(tle::TLE)
    epoch_year = tle.epoch_year
    epoch_day  = tle.epoch_day

    epoch_year_dt = epoch_year > 75 ?
        DateTime(1900 + epoch_year, 1, 1, 0, 0, 0) :
        DateTime(2000 + epoch_year, 1, 1, 0, 0, 0)

    epoch = datetime2julian(epoch_year_dt) + epoch_day - 1

    return epoch
end

"""
    tle_epoch(DateTime, tle::TLE) -> Float64

Return the `DateTime` related to the `tle` epoch.
"""
function tle_epoch(::Type{DateTime}, tle::TLE)
    epoch_year       = tle.epoch_year
    epoch_day        = tle.epoch_day
    i_epoch_day      = floor(Int, epoch_day)
    frac_of_day_s    = 86400 * (epoch_day - i_epoch_day)
    i_frac_of_day_s  = round(Int, frac_of_day_s)
    i_frac_of_day_ms = round(Int, (frac_of_day_s - i_frac_of_day_s) * 1e3)

    epoch = epoch_year > 75 ? _EPOCH_1900_DT : _EPOCH_2000_DT

    epoch += Year(epoch_year) +
             Day(i_epoch_day - 1) +
             Second(i_frac_of_day_s) +
             Millisecond(i_frac_of_day_ms)

    return epoch
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

# Get the mantissa and exponent of the number `n`.
function _get_mant_exp(n::Number)
    if abs(n) < 1e-20
        return 0., 0
    end

    exp  = floor(Int, log10(n)) + 1
    mant = n / 10.0^exp

    return mant, exp
end
