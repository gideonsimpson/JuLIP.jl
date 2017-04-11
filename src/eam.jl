
# implementation of EAM models using data files


@pot type EAM{T1, T2, T3} <: SitePotential
   ϕ::T1    # pair potential
   ρ::T2    # electron density potential
   F::T3   # embedding function
end

cutoff(V::EAM) = max(cutoff(V.ϕ), cutoff(V.ρ))

evaluate(V::EAM, r, R) = V.F( sum(V.ρ(r)) ) + sum(V.ϕ(r))

function evaluate_d(V::EAM, r, R)
   r = collect(r)
   dϕ = @D V.ϕ(r, R)
   ρ̄ = sum(V.ρ(r))
   dF = @D V.F(ρ̄)
   dρ = @D V.ρ(r, R)
   #          (ϕ' + F' * ρ') * ∇r
   return [ ((dϕ[n] + dF * dρ[n])/r[n]) * R[n]  for n = 1:length(r) ]
end


"""
`type EAM`

Generic Single-species EAM potential, to specify it, one needs to
specify the pair potential ϕ, the electron density ρ and the embedding
function F.

The most convenient constructor is likely via tabulated values,
more below.

# Constructors:
```
EAM(pair::PairPotential, eden::PairPotential, embed)
EAM(fpair::AbstractString, feden::AbstractString, fembed::AbstractString; kwargs...)
```

## Constructing an EAM potential from tabulated values

At the moment only the .plt format is implemented. Files can e.g. be
obtained from [NIST](https://www.ctcms.nist.gov/potentials/). Use the
`EAM(fpair, feden, fembed)` constructure. The keyword arguments
specify details of how the tabulated values are fitted; see
`?SplinePairPotential` for more details.

TODO: implement other file formats.
"""
EAM


function EAM(fpair::AbstractString, feden::AbstractString,
             fembed::AbstractString; kwargs...)
   pair = SplinePairPotential(fpair; kwargs...)
   eden = SplinePairPotential(feden; kwargs...)
   embed = SplinePairPotential(feden; fixcutoff = false, kwargs...)
   return EAM(pair, eden, embed)
end