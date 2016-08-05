
# wait for ReverseDiffSource to be updated to v0.5
# import ReverseDiffSource
# import ReverseDiffSource:rdiff

import SymPy
import SymPy: symbols

import FunctionWrappers
import FunctionWrappers: FunctionWrapper

typealias F64fun FunctionWrapper{Float64, Tuple{Float64}}


# ===========================================================================
#     macro that takes an expression, differentiates it
#     and returns anonymous functions for the derivatives
# ===========================================================================

"""
`diff2(ex::Expr)` :

takes an expression, differentiates it twice,
     and returns anonymous functions for the derivatives
"""
function diff2(ex::Expr)
   r = symbols("r")
   fsym = eval(ex)
   fsym_d = diff(fsym_d, r)
   fsym_dd = diff(fsym_dd, r)
   ex_d = parse(string(fsym_d))
   ex_dd = parse(string(fsym_dd))
   return eval( :( (r->$ex, r->$ex_d, r->$ex_dd)) )
end


# ================== Analytical Potentials ==========================
#
# TODO: this construction should not be restricted to pair potentials
#       but need a better model



# """
# `type AnalyticPotential <: PairPotential`
#
# ### Usage:
# ```julia
# lj = AnalyticPotential(:(r^(-12) - 2.0*r^(-6)), "LennardJones")
# println(lj)   # will output `LennardJones`
# A = 4.0; r0 = 1.234
# morse = AnalyticPotential("exp(-2.0*\$A*(r/\$r0-1.0)) - 2.0*exp(-\$A*(r/\$r0-1.0))",
#                            "Morse(A=\$A,r0=\$r0)")
# ```
#
# use kwarg `cutoff` to set a cut-off, default is `Inf`
# """


@pot type AnalyticPotential <: PairPotential
   f::F64fun
   f_d::F64fun
   f_dd::F64fun
   id::AbstractString
   cutoff::Float64
end
evaluate(p::AnalyticPotential, r) = p.f(r)
evaluate_d(p::AnalyticPotential, r) = p.f_d(r)
evaluate_dd(p::AnalyticPotential, r) = p.f_dd(r)
Base.string(p::AnalyticPotential) = p.id
cutoff(p::AnalyticPotential) = p.cutoff

# construct from string or expression
AnalyticPotential(s::AbstractString; id = s, cutoff=Inf) =
                        AnalyticPotential(parse(s), id=id, cutoff=cutoff)

function AnalyticPotential(ex::Expr; id = string(ex), cutoff=Inf)
   @assert isa(id, AbstractString)
   f, f_d, f_dd = diff2(ex)
   return AnalyticPotential(F64fun(f), F64fun(f_d), F64fun(f_dd), id, cutoff)
end