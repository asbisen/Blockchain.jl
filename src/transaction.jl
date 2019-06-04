# ################################################# #
# Transactions
# ################################################# #


struct TxInputs
  txid
  vout
  scriptsig_size
  scriptsig
  sequence
end

struct TxOutputs
  value
  scriptpubkey_size
  scriptpubkey
end

struct Transaction
  version
  segwit
  input_count 
  inputs::Vector{TxInputs}
  output_count 
  outputs::Vector{TxOutputs}
  locktime
end

struct Witness
  tx_witnesses_n
  component_length
  witness
end



function readtransactions(o::IOBuffer, ntx)
  transactions = []
  for tx in 1:ntx
    version = read(o, Int32)

    segwit = false
    tmp = read(o, Int16)
    if tmp == 256
      segwit = true
    else
      seek(o, (position(o)-2)) # seek back 2 bytes
    end

    (input_count, sz) = readvarint(o)
    inputs = []
    for inp in 1:input_count
      txid = bytes2hex(read(o, 32))
      vout = read(o, Int32)
      (scriptsig_size, sz) = readvarint(o)
      scriptsig = read(o, scriptsig_size) |>  bytes2hex
      sequence = read(o, 4) |> bytes2hex
      push!(inputs, TxInputs(txid, vout, scriptsig_size, scriptsig, sequence))
    end
    
    (output_count, sz) = readvarint(o)
    outputs = []
    for out in 1:output_count
      value = read(o, Int64)
      (scriptpubkey_size, sz) = readvarint(o)
      scriptpubkey = read(o, scriptpubkey_size) |> bytes2hex
      push!(outputs, TxOutputs(value, scriptpubkey_size, scriptpubkey))
    end
    
    if segwit == true
      for ix in 1:length(inputs) # for number of inputs
        (tx_witnesses_n, sz) = readvarint(o)
        for i in 1:tx_witnesses_n
          (component_length, sz) = readvarint(o)
          witness = read(o, component_length) |> bytes2hex
        end # for
      end # for
    end

    locktime = read(o, Int32)
    push!(transactions, Transaction(version, segwit, input_count, inputs,
                                    output_count, outputs, locktime))
  end # for tx                                  

  return transactions
end