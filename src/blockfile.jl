# ################################################# #
# BlockFile
# ################################################# #

struct BlockFile
  path::AbstractString
  num_blocks::Int
  offsets::Vector{Int}
end # BlockFile

function BlockFile(filename)
  path = abspath(filename)
  offsets = scanblocks(filename)
  num_blocks = length(offsets)
  BlockFile(path, num_blocks, offsets)
end # BlockFile


function Base.show(io::IO, b::BlockFile)
  println("Blockfile: $(b.path)")
  println("Number of Blocks: $(b.num_blocks)")
end # Base.show 


function scanblocks(filename)
  fd = open(filename, "r")
  stream = mmap(fd)
  offsets = []
  ptr = 0

  while ptr < (length(stream) - 4)
    if bytes2hex(stream[ptr+1:ptr+4]) == MAGIC
      push!(offsets, ptr+1)
      block_size = reinterpret(Int32, stream[ptr+5:ptr+8])[1]
      ptr += (8 + block_size)
    else
      @error "magic block $MAGIC expected but not found"
      return nothing
    end # if
  end # while
  close(fd)
  return offsets
end # scanblocks