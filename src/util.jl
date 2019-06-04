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
    val = reinterpret(UInt16, read(fd, 2))[1]
    sz = 3
  elseif dat == 0xfe
    val = reinterpret(UInt32, read(fd, 4))[1]
    sz = 5
  elseif dat == 0xff
    val = reinterpret(UInt64, read(fd, 8))[1]
    sz = 9
  else
    val = reinterpret(UInt8, dat)
    sz = 1
  end # if
  return (val, sz)
end # readvarint