-- Clipboard [Library]
-- Made By BETA

-- Libs
local ffi = require "ffi"

-- FFI Stuff
ffi.cdef [[ 
    void *GetProcAddress(void *, const char *);
    typedef void* HMODULE; HMODULE GetModuleHandleA(const char* lpModuleName);
]]

-- Functions
function vtable_entry(instance, index, typ)
    assert(instance ~= nil)
    assert(ffi.cast("void***", instance)[0] ~= nil)
    return ffi.cast(typ, (ffi.cast("void***", instance)[0])[index])
end

function vtable_bind(module, interface, index, typestring)
    local instance = mem.create_interface(interface)

    if (instance == nil) then
        client.log("Interface or Proc address is nil!")
        return
    end

    local fnptr = vtable_entry(instance, index, ffi.typeof(typestring))

    return function(...) return fnptr(instance, ...) end
end

-- Locals
local M = {}
local native_GetClipboardTextCount = vtable_bind("vgui2.dll", "VGUI_System", 7, "int(__thiscall*)(void*)")
local native_SetClipboardText = vtable_bind("vgui2.dll", "VGUI_System", 9, "void(__thiscall*)(void*, const char*, int)")
local native_GetClipboardText = vtable_bind("vgui2.dll", "VGUI_System", 11, "int(__thiscall*)(void*, int, const char*, int)")

local new_char_arr = ffi.typeof("char[?]")

-- Another Functions
function M.get()
	local len = native_GetClipboardTextCount()

	if len > 0 then
		local char_arr = new_char_arr(len)
		native_GetClipboardText(0, char_arr, len)
		return ffi.string(char_arr, len-1)
	end
end

function M.set(text)
	text = tostring(text)

	native_SetClipboardText(text, string.len(text))
end

-- Executes
M.paste = M.get
M.copy = M.set

-- Returns
return M