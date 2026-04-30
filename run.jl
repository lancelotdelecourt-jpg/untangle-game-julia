import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

include(joinpath(@__DIR__, "src", "Main.jl"))
Untangle.run_game()
