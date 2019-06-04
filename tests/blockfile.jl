import Mmap: mmap 
import Dates: unix2datetime

fn = "/Users/abisen/Code/jbt/data/blk00500.dat"
const MAGIC = "f9beb4d9"

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
  return offsets
end # scanblocks


# ################################################# #
# BlockHeader
# ################################################# #

struct BlockHeader
  version
  hashPrevBlock
  hashMerkleRoot
  time
  bits
  nonce
end # BlockHeader

function BlockHeader(data::Vector{UInt8})
  version = reinterpret(Int32, data[1:4])[1]
  hashPrevBlock = bytes2hex(data[5:36])
  hashMerkleRoot = bytes2hex(data[37:68])
  time = unix2datetime(reinterpret(Int32, data[69:72])[1])
  bits = reinterpret(Int32, data[73:76])[1]
  nonce = reinterpret(Int32, data[77:80])[1]
  BlockHeader(version, hashPrevBlock, hashMerkleRoot, time, bits, nonce)
end


function Base.show(io::IO, o::BlockHeader)
  println("version: $(o.version)")
  println("hashPrevBlock: $(o.hashPrevBlock)")
  println("hashMerkleRoot: $(o.hashMerkleRoot)")
  println("time: $(o.time)")
end # Base.show


function readblock(b::BlockFile, n::Int)
  (n > b.num_blocks) && (@error "$n > total blocks $(b.num_blocks)")

  fd = open(b.path, "r")
  seek(fd, b.offsets[n]-1)

  magic = bytes2hex(read(fd, 4))
  if magic != MAGIC
    @error "did not find $MAGIC while reading block"
  end

  block_size = reinterpret(Int32, read(fd, 4))[1]
  header = BlockHeader(read(fd, 80))
  (ntx, sz) = readvarint(fd)
  body = read(fd, (block_size-80-sz))

  Block(magic, block_size, header, ntx, body)
end # readblock


"""
  readvarint(fd::IOStream)

Read a VarInt from fd with the following logic. The function
would read 1 byte first and evaluate based on the content.

```
  x <  0xfd = (val =  x)
  x == 0xfd = (val = next 2 bytes)
  x == 0xfe = (val = next 4 bytes)
  x == 0xff = (val = next 8 bytes)
```

Returns a tuple containing (value, size) where size represents
number of bytes the pos of IOStream  was changed by. 
"""
function readvarint(fd)
  dat = read(fd, 1)[1]
  if dat == 0xfd
    val = reinterpret(Int16, read(fd, 2))[1]
    sz = 3
  elseif dat == 0xfe
    val = reinterpret(Int32, read(fd, 4))[1]
    sz = 5
  elseif dat == 0xff
    val = reinterpret(Int64, read(fd, 8))[1]
    sz = 9
  else
    val = reinterpret(Int8, dat)
    sz = 1
  end # if
  return (val, sz)
end # readvarint


# ################################################# #
# Block
# ################################################# #

struct Block
  magic::AbstractString
  size::Int
  header::BlockHeader
  numtx::Int
  transactions::Array{UInt8}
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





function tx(o::IOBuffer)
  version = read(o, Int32)
  
  segwit = false
  tmp = read(o, Int16)
  if tmp == 256
    segwit = true
  else
    seek(o, (position(o)-2)) # seek back 2 bytes
  end

  @show (val, sz) = readvarint(o)
  txhash = read(o, 32)
  
  return (version, segwit, val, txhash)
end

t=b[22].transactions;
f=IOBuffer(t);
tx(f)
