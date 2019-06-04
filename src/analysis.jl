
"""
  txvalue(o::Transaction)

Returns the total value of a transaction
"""
txvalue(o::Transaction) = sum([o.outputs[i].value for i in 1:o.output_count])
