module Types
  Handle = Types::Uint32.typedef("Handle")
  SessionHandle = Types::Handle.typedef("SessionHandle")  
  MemInfo = StructType.new("MemInfo") do
    field Types::Void.pointer, :base # virtual address
    field Types::Uint64, :size
    field Types::Uint32, :memory_type
    field Types::Uint32, :memory_attribute
    field Types::Uint32, :permission
    field Types::Uint32, :ipc_ref_count
    field Types::Uint32, :device_ref_count
    field Types::Uint32, :padding
  end
  PageInfo = StructType.new("PageInfo") do
    field Types::Uint64, :pageFlags
    # lower 8 bits:
    #  0x3: code static .text and .rodata
    #  0x4: code .data
    #  0x5: heap
    #  0x6: shared memory block
    #  0x8: module code static .text and .rodata
    #  0x9: module code
    #  0xB: stack mirror
    #  0xC: thread local storage
    #  0xE: memory mirror
    #  0x10: reserved
    # bit32: is_mirrored
    # bit32: is_uncached?
  end
end

class Pointer
  def query_mem
    mi = Kernel.new Types::MemInfo
    pi = Kernel.new Types::PageInfo
    r = Transistor::LL::SVC::query_memory(mi, pi, self.to_i)
    if r != 0 then
      throw r
    end
    val = mi.deref
    Kernel.free(mi)
    Kernel.free(pi)
    return val
  end
end
