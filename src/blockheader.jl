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
  # body = read(fd, (block_size-80-sz))
  transactions = readtransactions(read(fd, (block_size-80-sz))|> IOBuffer, ntx)
  
  close(fd)
  Block(magic, block_size, header, ntx, transactions)
end # readblock