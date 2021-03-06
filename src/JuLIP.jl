
# JuLIP.jl master file.

module JuLIP

using PyCall, Reexport

export Atoms

# TODO: correctly use import versus using throughout this package!

# quickly switch between Matrices and Vectors of Vecs
include("arrayconversions.jl")

# define types and abstractions of generic functions
include("abstractions.jl")

# a few auxiliary routines
include("utils.jl")

# implementation of some key functionality via ASE
include("ASE.jl")
@reexport using JuLIP.ASE

# define the default atoms object
"""
`type Atoms`

Technically not a type but a type-alias, to possibly allow different "backends".
At the moment, `Atoms = ASE.ASEAtoms`; see its help for more details.
This will likely remain for the foreseeable future.
"""
const Atoms = ASE.ASEAtoms

# only try to import Visualise, it is not needed for the rest to work.
try
   # some visualisation options
   if isdefined(Main, :JULIPVISUALISE)
      if Main.JULIPVISUALISE == true
         include("Visualise.jl")
      end
   end
catch
   JuLIP.julipwarn("""JuLIP.Visualise did not import correctly, probably because
               `imolecule` is not correctly installed.""")
end

# interatomic potentials prototypes and some example implementations
include("Potentials.jl")

# submodule JuLIP.Constraints
include("Constraints.jl")
@reexport using JuLIP.Constraints

# basic preconditioning capabilities
include("preconditioners.jl")

# some solvers
include("Solve.jl")
@reexport using JuLIP.Solve

# experimental features
include("Experimental.jl")
@reexport using JuLIP.Experimental

# codes to facilitate testing
include("Testing.jl")

end # module
