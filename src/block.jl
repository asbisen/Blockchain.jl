# ################################################# #
# Block
# ################################################# #

struct Block
  magic::AbstractString
  size::Int
  header::BlockHeader
  numtx::Int
  transactions::Array{Transaction}
end #  Block

function Base.show(io::IO,  o::Block)
  println("Magic:  $(o.magic)")
  println("Size:  $(o.size)")
  println("Num Tx: $(o.numtx)")
  println("\n\nHEADER")
  println("$(o.header)")
end # Base.show

Base.length(o::BlockFile) = o.num_blocks
Base.lastindex(o::BlockFile) = o.num_blocks

Base.getindex(o::BlockFile, n::Int) = readblock(o, n)
Base.getindex(o::BlockFile, r::UnitRange) = getindex(o, collect(r))
Base.getindex(o::BlockFile, r::StepRange) = getindex(o, collect(r))
function Base.getindex(o::BlockFile, v::Vector{Int})
  res = []
  for idx in v
    push!(res, readblock(o, idx))
  end
  res
end