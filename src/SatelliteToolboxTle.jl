module SatelliteToolboxTle

using Crayons
using Downloads
using Dates
using Printf
using URIs

import Base: convert, show

############################################################################################
#                                        Constants
############################################################################################

# Escape sequences related to the crayons.
const _D = Crayon(reset = true)
const _B = crayon"bold"
const _G = crayon"bold green"
const _U = crayon"bold blue"
const _Y = crayon"bold yellow"

# Epochs.
const _EPOCH_1900_DT = DateTime(1900, 1, 1, 0, 0, 0)
const _EPOCH_2000_DT = DateTime(2000, 1, 1, 0, 0, 0)

const _EPOCH_1900_JD = DateTime(1900, 1, 1, 0, 0, 0) |> datetime2julian
const _EPOCH_2000_JD = DateTime(2000, 1, 1, 0, 0, 0) |> datetime2julian

############################################################################################
#                                          Types
############################################################################################

include("types.jl")

############################################################################################
#                                         Includes
############################################################################################

include("conversion.jl")
include("checksum.jl")
include("parse.jl")
include("read.jl")
include("show.jl")

include("./fetcher/api.jl")
include("./fetcher/celestrak.jl")

include("precompile.jl")

end
