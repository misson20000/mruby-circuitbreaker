module Types
  Void		= NumericType.new("void",    "C",  1)
  Char		= NumericType.new("char",    "C",  1)
  Uint8		= NumericType.new("uint8",   "C",  1)
  Uint16	= NumericType.new("uint16",  "S<", 2)
  Uint32	= NumericType.new("uint32",  "L<", 4)
  Uint64	= NumericType.new("uint64",  "Q<", 8)
  Int8		= NumericType.new("int8",    "c",  1)
  Int16		= NumericType.new("int16",   "s<", 2)
  Int32		= NumericType.new("int32",   "l<", 4)
  Int64		= NumericType.new("int64",   "q<", 8)
  Float64	= NumericType.new("float32", "E",  8)
  Bool		= BooleanType.new

  class << Float64
    def coerce_to_argument(value)
      [value].pack("E").unpack("L<L<")
    end
    
    def coerce_from_return(switch, pair)
      pair.pack("L<L<").unpack("E")[0]
    end
  end
  
  class << Void
    def is_supported_return_type?
      true
    end
  end
end

def malloc(size)
  return make_pointer(Transistor::LL::malloc(size))
end

def alloc_pages(min, max=min)
  ap = Transistor::LL::alloc_pages(min, max)
  return [make_pointer(ap[0]), ap[1]]
end

def free_pages(ptr)
  Transistor::LL::free_pages(ptr.to_i)
end

def free(pointer)
  Transistor::LL::free(pointer.to_i)
end

def read(pointer, offset, length)
  return Transistor::LL::read(pointer.to_i + offset, length)
end

def write(pointer, offset, data)
  Transistor::LL::write(pointer.to_i + offset, data)
end

def new(type, count=1)
  malloc(type.size * count).cast!(type)
end

def make_pointer(addr)
  Pointer.new(self, addr)
end
  
def nullptr
  make_pointer(0)
end
  
def string_buf(string)
  buf = malloc(string.length + 1)
  buf.cast! Types::Char
  buf.write(string)
  buf[string.length] = 0
  return buf
end

def hexedit(loc)
  memio = AsynchronousMemoryInterface.new(self)
  memio.open do
    Visual::Mode.standalone do |vism|
      Visual::MemoryEditorPanel.new(vism, loc.to_i, [], memio)
    end
  end
end
