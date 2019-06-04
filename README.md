# Blockchain (BLK) File Parser

A very basic and probably brittle blk file parser in Julia.  

## Installation

```julia
julia> ]
(v1.1) pkg> dev https://github.com/asbisen/Blockchain.jl.git
```

## Usage

```julia
using Blockchain

blkf=BlockFile("blk01650.dat") 
println(blkf.num_blocks)

# Retrieve a Block
julia> block=blkf[10]

Magic:  f9beb4d9
Size:  1139853
Num Tx: 2591

HEADER
version: 536870912
hashPrevBlock: 3c456d6dc752b6a636746ac7fa620f57c1c5e3d622001f000000000000000000
hashMerkleRoot: 2242c84229c47200911000fa1d6524d85c88a0da8914b844c8d43a1167d7cf1d
time: 2019-05-23T05:48:17

#Retieve Transactions
julia> block.transactions[1].outputs

4-element Array{Blockchain.TxOutputs,1}:
 Blockchain.TxOutputs(1337526058, 0x19, "76a914c825a1ecf2a6830c4401620c3a16f1995057c2ab88ac")
 Blockchain.TxOutputs(0, 0x2f, "6a24aa21a9ed86c15e15250ddf4a34daf0fff7178a2a7fa2df71549f2de524bb37c3f86ee4c1080000000000000000")
 Blockchain.TxOutputs(0, 0x2c, "6a4c2952534b424c4f434b3a0f884dd29979b15061897c391d3258922cd6787cd69747fe7dbe62f29f5cbcfc")
 Blockchain.TxOutputs(0, 0x26, "6a24b9e11b6d3394af7324ec8e4f287f256ac2c7331e0f485421c3feb60ba3af7c58cc34058b")

```

## TODO

- [ ] Add a check to ensure reads dont overflow to subsequent records
- [ ] BlockFile should be iterator of Blocks in the file
