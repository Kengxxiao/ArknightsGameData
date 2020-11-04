-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local eutil = CS.Torappu.Lua.Util

---@class HomeHotfixer:HotfixBase
local HomeHotfixer = Class("HomeHotfixer", HotfixBase)

local function _StopVoiceWhenExit()
end

function HomeHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Home.HomePage)
  self:Fix_ex(CS.Torappu.UI.Home.HomePage, "_StopVoiceWhenExit", _StopVoiceWhenExit)
end

function HomeHotfixer:OnDispose()
end

return HomeHotfixer