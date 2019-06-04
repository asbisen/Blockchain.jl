module Blockchain


import Dates: unix2datetime
import Mmap: mmap 


include("util.jl")
include("blockfile.jl")
include("blockheader.jl")
include("transaction.jl")
include("block.jl")
include("analysis.jl")


const MAGIC = "f9beb4d9"


export BlockFile

export txvalue


end # module