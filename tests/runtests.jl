using Test
using Blockchain

rootdir = abspath(joinpath(dirname(@__FILE__), ".."))

@testset "Simple Reading" begin
  blkfile = BlockFile(rootdir*"/data/blk00500.dat")
  @test blkfile.num_blocks == 171

  blkfile = BlockFile(rootdir*"/data/blk00000.dat")
  @test blkfile.num_blocks == 119963

  blkfile = BlockFile(rootdir*"/data/blk01650.dat")
  @test blkfile.num_blocks == 109
end #testset

@testset "Count Transactions" begin
  blkfile = BlockFile(rootdir*"/data/blk00500.dat")
  @test (blkfile[100].transactions |> length) == 1298

  blkfile = BlockFile(rootdir*"/data/blk01650.dat")
  @test (blkfile[19].transactions |> length) == 2930
end # testset