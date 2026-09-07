module SatelliteToolboxTle

using Dates
using Downloads

using URIs

import Base: convert, show
import SatelliteToolboxBase: PrintedField, PrintedSection, print_tree, print_tree_body

############################################################################################
#                                        Constants                                         #
############################################################################################

# Two-digit epoch years greater than or equal to this value refer to the 20th century, and
# the others to the 21st century, as defined by the SGP4 reference implementation.
const _EPOCH_YEAR_PIVOT = 57

# Letters used by the Alpha-5 scheme to encode the first digits of the satellite catalog
# numbers above 99999. The letters `I` and `O` are skipped, and the value of each letter is
# its index in this string plus 9 (`A` = 10, `B` = 11, ..., `Z` = 33).
const _ALPHA5_LETTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ"

# Maximum satellite catalog number that can be represented with the Alpha-5 scheme.
const _MAX_SATELLITE_NUMBER = 339_999

# Powers of ten used to scale the integer mantissas of the TLE fields with an implied
# decimal point. Dividing or multiplying an integer by one of those values is correctly
# rounded, since both operands are exactly representable. The element `i` is `10^(i - 1)`.
const _POWERS_OF_TEN = (
    1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14
)

############################################################################################
#                                          Types                                           #
############################################################################################

include("./types.jl")

############################################################################################
#                                         Includes                                         #
############################################################################################

include("./checksum.jl")
include("./conversion.jl")
include("./parse.jl")
include("./read.jl")
include("./show.jl")
include("./write.jl")

include("./fetcher/api.jl")
include("./fetcher/celestrak.jl")

include("./precompile.jl")

end # module SatelliteToolboxTle
