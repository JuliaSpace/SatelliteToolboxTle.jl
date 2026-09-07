## Description #############################################################################
#
# Functions to print the TLE.
#
# The rich representation is a tree drawn with the helpers of SatelliteToolboxBase.jl, with
# the same layout as the orbit data messages of SatelliteToolboxOrbitDataMessages.jl: the
# header carries the satellite name and the epoch, and the fields of each TLE line are
# grouped under a tree node.
#
############################################################################################

############################################################################################
#                                        Overloads                                         #
############################################################################################

function show(io::IO, tle::TLE)
    print(
        io,
        "TLE: ",
        tle.name,
        " [",
        tle.satellite_number,
        "] (Epoch = ",
        tle_epoch(DateTime, tle),
        ")",
    )

    return nothing
end

function show(io::IO, ::MIME"text/plain", tle::TLE)
    header = string("TLE: ", tle.name, " (Epoch = ", tle_epoch(DateTime, tle), ")")
    print_tree(io, header, tle)
    return nothing
end

# The body of the rich representation is overloaded so that other types can print it under
# their own header.
function print_tree_body(io::IO, tle::TLE)
    line_1_fields = PrintedField[
        ("Satellite Number",         string(tle.satellite_number),         ""),
        ("Classification",           string(tle.classification),           ""),
        ("International Designator", tle.international_designator,         ""),
        ("Epoch Year",               string(tle.epoch_year),               ""),
        ("Epoch Day",                string(tle.epoch_day),                ""),
        ("ṅ/2",                      string(tle.dn_o2),                    "rev/day²"),
        ("n̈/6",                      string(tle.ddn_o6),                   "rev/day³"),
        ("B*",                       string(tle.bstar),                    "1/ER"),
        ("Ephemeris Type",           string(tle.ephemeris_type),           ""),
        ("Element Set Number",       string(tle.element_set_number),       ""),
    ]

    line_2_fields = PrintedField[
        ("Inclination",              string(tle.inclination),         "°"),
        ("RA of the Ascending Node", string(tle.raan),                "°"),
        ("Eccentricity",             string(tle.eccentricity),        ""),
        ("Arg. of Perigee",          string(tle.argument_of_perigee), "°"),
        ("Mean Anomaly",             string(tle.mean_anomaly),        "°"),
        ("Mean Motion",              string(tle.mean_motion),         "rev/day"),
        ("Revolution Number",        string(tle.revolution_number),   ""),
    ]

    sections = PrintedSection[
        PrintedSection("Line 1", line_1_fields),
        PrintedSection("Line 2", line_2_fields),
    ]

    print_tree_body(io, PrintedField[], sections)

    return nothing
end
