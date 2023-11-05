module POGA

include("NumberOrExpr.jl")
include("Cone.jl")
include("CombinationOfCones.jl")
include("EliminateCoordinates.jl")
include("MacmahonLifting.jl")

export
# Types
    NumberOrExpr,
    Ray,
    Cone,
    CombinationOfCones,
# Functions
    MacmahonLifting,
    EliminateLastCoordinate,
    EliminateLastCoordinate2,
    EliminateCoordinates,
    EliminateCoordinates2

end
