addon.name      = 'OpenMenu';
addon.author    = 'Thorny';
addon.version   = '1.00';
addon.desc      = 'Opens Menu on command';
addon.link      = 'https://github.com/ThornyFFXI/';

require('common');
-- Major credit to atom0s for outlining where these functions are and their calling conventions.
local ffi = require('ffi')
ffi.cdef[[
    typedef int32_t (__cdecl *FUNC_KaMenuMagicOpenMenu)(int32_t, uint8_t, uint32_t);
    typedef int32_t (__cdecl *FsShortcutManager_DoWeaponAbility)();
    typedef int32_t (__cdecl *FUNC_KaMenuAbilityOpenMenu)(int32_t, int32_t, int32_t);
]]

local address = ashita.memory.find(0, 0, 'E8????????6A016A0084C074??6A14E8', 0, 0);
local OpenWSMenu =  ffi.cast('FsShortcutManager_DoWeaponAbility', address);
address = address + 15;
local offset = ashita.memory.read_int32(address + 1);
local OpenMenu = ffi.cast('FUNC_KaMenuAbilityOpenMenu', address+offset+5);
address = ashita.memory.find(0, 0, "68000100006A016A00E8????????83", 0, 0);
address = address + 9;
offset = ashita.memory.read_int32(address + 1);
local OpenMagicMenu = ffi.cast('FUNC_KaMenuMagicOpenMenu', address+offset+5);

local subMenus = T{
    ['ja'] = function() OpenMenu(1, 0, 1) end,
    ['pet'] = function() OpenMenu(2, 0, 1) end,
    ['ws'] = function() OpenWSMenu() end,
    ['trait'] = function() OpenMenu(4, 0, 1) end,
    ['bprage'] = function() OpenMenu(6, 0, 1) end,
    ['corroll'] = function() OpenMenu(8, 0, 1) end,
    ['quickdraw'] = function() OpenMenu(9, 0, 1) end,
    ['bpward'] = function() OpenMenu(10, 0, 1) end,
    ['magic'] = function() OpenMagicMenu(0, 0, 0x100) end,
    ['whitemagic'] = function() OpenMagicMenu(1, 0, 0x100) end,
    ['blackmagic'] = function() OpenMagicMenu(2, 0, 0x100) end,
    ['summoning'] = function() OpenMagicMenu(3, 0, 0x100) end,
    ['ninjutsu'] = function() OpenMagicMenu(4, 0, 0x100) end,
    ['songs'] = function() OpenMagicMenu(5, 0, 0x100) end,
    ['bluemagic'] = function() OpenMagicMenu(6, 0, 0x100) end,
    ['geomancy'] = function() OpenMagicMenu(7, 0, 0x100) end,
    ['trusts'] = function() OpenMagicMenu(8, 1, 0) end,
}

ashita.events.register('command', 'OpenMenu_HandleCommand', function (e)
    local args = e.command:args();
    if (args[1] == '/openmenu') then
        if #args > 1 then
            local func = subMenus[string.lower(args[2])];
            if func then func(args[3]) end
        end
        e.blocked = true;
    end
end);