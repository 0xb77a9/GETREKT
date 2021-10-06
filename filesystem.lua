-- Filesystem
-- Made By BETA

-- Libs
local ffi = require "ffi"

-- FFI Stuff
ffi.cdef [[
    typedef void* (__cdecl* tCreateInterface)(const char* name, int* returnCode);
    void* GetProcAddress(void* hModule, const char* lpProcName);
    void* GetModuleHandleA(const char* lpModuleName);
]]

-- Locals
local filesystem = mem.create_interface("VBaseFileSystem")

local filesystem_class = ffi.cast(ffi.typeof("void***"), filesystem)
local filesystem_vftbl = filesystem_class[0]

local func_read_file = ffi.cast("int (__thiscall*)(void*, void*, int, void*)",
                                filesystem_vftbl[0])
local func_write_file = ffi.cast(
                            "int (__thiscall*)(void*, void const*, int, void*)",
                            filesystem_vftbl[1])

local func_open_file = ffi.cast(
                           "void* (__thiscall*)(void*, const char*, const char*, const char*)",
                           filesystem_vftbl[2])
local func_close_file = ffi.cast("void (__thiscall*)(void*, void*)",
                                 filesystem_vftbl[3])

local func_get_file_size = ffi.cast("unsigned int (__thiscall*)(void*, void*)",
                                    filesystem_vftbl[7])
local func_file_exists = ffi.cast(
                             "bool (__thiscall*)(void*, const char*, const char*)",
                             filesystem_vftbl[10])

local full_filesystem = mem.create_interface("VFileSystem")
local full_filesystem_class = ffi.cast(ffi.typeof("void***"), full_filesystem)
local full_filesystem_vftbl = full_filesystem_class[0]

local func_add_search_path = ffi.cast(
                                 "void (__thiscall*)(void*, const char*, const char*, int)",
                                 full_filesystem_vftbl[11])
local func_remove_search_path = ffi.cast(
                                    "bool (__thiscall*)(void*, const char*, const char*)",
                                    full_filesystem_vftbl[12])

local func_remove_file = ffi.cast(
                             "void (__thiscall*)(void*, const char*, const char*)",
                             full_filesystem_vftbl[20])
local func_rename_file = ffi.cast(
                             "bool (__thiscall*)(void*, const char*, const char*, const char*)",
                             full_filesystem_vftbl[21])
local func_create_dir_hierarchy = ffi.cast(
                                      "void (__thiscall*)(void*, const char*, const char*)",
                                      full_filesystem_vftbl[22])
local func_is_directory = ffi.cast(
                              "bool (__thiscall*)(void*, const char*, const char*)",
                              full_filesystem_vftbl[23])

local func_find_first = ffi.cast(
                            "const char* (__thiscall*)(void*, const char*, int*)",
                            full_filesystem_vftbl[32])
local func_find_next = ffi.cast("const char* (__thiscall*)(void*, int)",
                                full_filesystem_vftbl[33])
local func_find_is_directory = ffi.cast("bool (__thiscall*)(void*, int)",
                                        full_filesystem_vftbl[34])
local func_find_close = ffi.cast("void (__thiscall*)(void*, int)",
                                 full_filesystem_vftbl[35])

local MODES = {
    ["r"] = "r",
    ["w"] = "w",
    ["a"] = "a",
    ["r+"] = "r+",
    ["w+"] = "w+",
    ["a+"] = "a+",
    ["rb"] = "rb",
    ["wb"] = "wb",
    ["ab"] = "ab",
    ["rb+"] = "rb+",
    ["wb+"] = "wb+",
    ["ab+"] = "ab+"
}

local filesystem = {}
filesystem.__index = filesystem

-- Functions
function filesystem.exists(file, path_id)
    return func_file_exists(filesystem_class, file, path_id)
end

function filesystem.rename(old_path, new_path, path_id)
    func_rename_file(full_filesystem_class, old_path, new_path, path_id)
end

function filesystem.remove(file, path_id)
    func_remove_file(full_filesystem_class, file, path_id)
end

function filesystem.create_directory(path, path_id)
    func_create_dir_hierarchy(full_filesystem_class, path, path_id)
end

function filesystem.is_directory(path, path_id)
    return func_is_directory(full_filesystem_class, path, path_id)
end

function filesystem.find_first(path)
    local handle = ffi.new("int[1]")
    local file = func_find_first(full_filesystem_class, path, handle)
    if file == ffi.NULL then return nil end

    return handle, ffi.string(file)
end

function filesystem.find_next(handle)
    local file = func_find_next(full_filesystem_class, handle)
    if file == ffi.NULL then return nil end

    return ffi.string(file)
end

function filesystem.find_is_directory(handle)
    return func_find_is_directory(full_filesystem_class, handle)
end

function filesystem.find_close(handle)
    func_find_close(full_filesystem_class, handle)
end

function filesystem.add_search_path(path, path_id, type)
    func_add_search_path(full_filesystem_class, path, path_id, type)
end

function filesystem.remove_search_path(path, path_id)
    func_remove_search_path(full_filesystem_class, path, path_id)
end

function filesystem.open(file, mode, path_id)
    if not MODES[mode] then error("Invalid mode!") end
    local self = setmetatable({
        file = file,
        mode = mode,
        path_id = path_id,
        handle = func_open_file(filesystem_class, file, mode, path_id)
    }, filesystem)

    return self
end

function filesystem:get_size()
    return func_get_file_size(filesystem_class, self.handle)
end

function filesystem:write(buffer)
    func_write_file(filesystem_class, buffer, #buffer, self.handle)
end

function filesystem:read()
    local size = self:get_size()
    local output = ffi.new("char[?]", size + 1)
    func_read_file(filesystem_class, output, size, self.handle)

    return ffi.string(output)
end

function filesystem:close() func_close_file(filesystem_class, self.handle) end

-- Returns
return filesystem