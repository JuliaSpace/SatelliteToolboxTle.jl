## Description #############################################################################
#
# Functions to print the TLE.
#
############################################################################################

############################################################################################
#                                        Overloads                                         #
############################################################################################

function show(io::IO, tle::TLE)
    print(io, "TLE: ", tle.name, " (Epoch = ", tle_epoch(DateTime, tle), ")")
    return nothing
end

function show(io::IO, mime::MIME"text/plain", tle::TLE)
    color = get(io, :color, false)
    return _show_tle(io, tle; color = color)
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _show_tle(io::IO, tle::TLE; color::Bool = true) -> Nothing

Show the TLE `tle` in the IO `io`.

# Keywords

- `color::Bool`: If `true`, the text will be printed using colors. (**Default** = `true`)
"""
function _show_tle(io::IO, tle::TLE; color::Bool = true)
    # Colors will be printed only for STDOUT.
    b = color ? _B : ""
    d = color ? _D : ""
    g = color ? _G : ""
    y = color ? _Y : ""

    # Auxiliary variables.
    name                     = tle.name

    satellite_number         = tle.satellite_number
    international_designator = tle.international_designator
    epoch_year               = tle.epoch_year
    epoch_day                = tle.epoch_day
    epoch_datetime           = tle_epoch(DateTime, tle)
    element_set_number       = tle.element_set_number
    dn_o2                    = tle.dn_o2
    ddn_o6                   = tle.ddn_o6
    bstar                    = tle.bstar

    inclination              = tle.inclination
    raan                     = tle.raan
    eccentricity             = tle.eccentricity
    argument_of_perigee      = tle.argument_of_perigee
    mean_anomaly             = tle.mean_anomaly
    mean_motion              = tle.mean_motion
    revolution_number        = tle.revolution_number

    # Print the TLE information.
    print(io, "TLE:\n")
    print(io, "$(b)                      Name : $(d)"); @printf(io, "%s\n",                name)
    print(io, "$(b)          Satellite number : $(d)"); @printf(io, "%d\n",                satellite_number)
    print(io, "$(b)  International designator : $(d)"); @printf(io, "%s\n",                international_designator)
    print(io, "$(b)        Epoch (Year / Day) : $(d)"); @printf(io, "%d / %12.8f (%s)\n",  epoch_year, epoch_day, epoch_datetime)
    print(io, "$(b)        Element set number : $(d)"); @printf(io, "%d\n",                element_set_number)
    print(io, "$(b)              Eccentricity : $(d)"); @printf(io, "%12.8f\n",            eccentricity)
    print(io, "$(b)               Inclination : $(d)"); @printf(io, "%12.8f deg\n",        inclination)
    print(io, "$(b)                      RAAN : $(d)"); @printf(io, "%12.8f deg\n",        raan)
    print(io, "$(b)       Argument of perigee : $(d)"); @printf(io, "%12.8f deg\n",        argument_of_perigee)
    print(io, "$(b)              Mean anomaly : $(d)"); @printf(io, "%12.8f deg\n",        mean_anomaly)
    print(io, "$(b)           Mean motion (n) : $(d)"); @printf(io, "%12.8f revs / day\n", mean_motion)
    print(io, "$(b)         Revolution number : $(d)"); @printf(io, "%d\n",                revolution_number)
    print(io, "$(b)                        B* : $(d)"); @printf(io, "%12g 1 / er\n",       bstar)
    print(io, "$(b)                     ṅ / 2 : $(d)"); @printf(io, "%12g rev / day²\n",   dn_o2)
    print(io, "$(b)                     n̈ / 6 : $(d)"); @printf(io, "%12g rev / day³",     ddn_o6)

    return nothing
end
