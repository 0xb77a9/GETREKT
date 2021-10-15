local ffi = require("ffi")

ffi.cdef "typedef uintptr_t (__thiscall* GetClientEntity_4242425_t)(void*, int)"
local IClientEntityList = ffi.cast(ffi.typeof("void***"),
                                   mem.create_interface("VClientEntityList"));

local GetHighestEntityIndex = ffi.cast(ffi.typeof("int(__thiscall*)(void*)"),
                                       IClientEntityList[0][6]);

local entity_list_ptr = ffi.cast("void***",
                                 mem.create_interface("VClientEntityList"));
local get_client_entity_fn = ffi.cast("GetClientEntity_4242425_t",
                                      entity_list_ptr[0][3]);

local Entities = {}
Find = {
    FindByClass = function(name)
	    for i = 1, #Entities do Entities[i] = nil end
        for i = 0, GetHighestEntityIndex(IClientEntityList) do
            if entity.get_classname(i) == name then
                table.insert(Entities, i)
            end
        end
        return Entities
    end
}
return Find