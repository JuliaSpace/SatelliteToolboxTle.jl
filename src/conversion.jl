## Description #############################################################################
#
# Functions to convert the TLE epoch to other representations.
#
############################################################################################

export tle_epoch

############################################################################################
#                                     Public Functions                                     #
############################################################################################

"""
    tle_epoch(tle::TLE) -> Float64

Return the Julian day [UTC] related to the `tle` epoch.

The two-digit epoch year is interpreted according to the SGP4 reference implementation:
years from 57 to 99 refer to the 20th century, and years from 0 to 56 to the 21st century.
"""
function tle_epoch(tle::TLE)
    year_jd = datetime2julian(DateTime(_tle_epoch_year(tle.epoch_year)))
    return year_jd + tle.epoch_day - 1
end

"""
    tle_epoch(DateTime, tle::TLE) -> DateTime

Return the `DateTime` [UTC] related to the `tle` epoch, rounded to the millisecond.

The two-digit epoch year is interpreted according to the SGP4 reference implementation:
years from 57 to 99 refer to the 20th century, and years from 0 to 56 to the 21st century.
"""
function tle_epoch(::Type{DateTime}, tle::TLE)
    year_dt = DateTime(_tle_epoch_year(tle.epoch_year))
    return year_dt + Millisecond(round(Int, (tle.epoch_day - 1) * 86_400_000))
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _datetime_to_tle_epoch(epoch::DateTime) -> Int, Float64

Convert the `epoch` [UTC] to the two-digit epoch year and the epoch day of the year plus
its fraction [days] used by the TLE format. An `ArgumentError` is thrown if `epoch` is
outside the years that can be represented in a TLE (from 1957 to 2056).
"""
function _datetime_to_tle_epoch(epoch::DateTime)
    epoch_year = year(epoch)

    (1900 + _EPOCH_YEAR_PIVOT <= epoch_year < 2000 + _EPOCH_YEAR_PIVOT) || throw(
        ArgumentError(
            "The epoch year must be in the interval [$(1900 + _EPOCH_YEAR_PIVOT), " *
            "$(2000 + _EPOCH_YEAR_PIVOT - 1)] to be represented in a TLE.",
        ),
    )

    day_ms    = Dates.value(epoch - DateTime(Date(epoch)))
    epoch_day = dayofyear(epoch) + day_ms / 86_400_000

    return mod(epoch_year, 100), epoch_day
end

"""
    _tle_epoch_year(epoch_year::Int) -> Int

Return the four-digit year related to the two-digit TLE `epoch_year`, using the SGP4
reference pivot: years from 57 to 99 refer to the 20th century, and years from 0 to 56 to
the 21st century.
"""
function _tle_epoch_year(epoch_year::Int)
    return epoch_year >= _EPOCH_YEAR_PIVOT ? 1900 + epoch_year : 2000 + epoch_year
end
