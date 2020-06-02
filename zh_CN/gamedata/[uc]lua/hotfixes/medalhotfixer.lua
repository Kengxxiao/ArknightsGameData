-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local eutil = CS.Torappu.Lua.Util

---@class MedalHotfixer:HotfixBase
local MedalHotfixer = Class("MedalHotfixer", HotfixBase)

local function fixUIObj(self,viewModelList,refreshFlag)
  if (self._scrollRect.verticalScrollbar~=nil) then
    self._scrollRect.verticalScrollbar.gameObject:SetActive(false)
    self._scrollRect.verticalScrollbar = nil
    local tempRect = self._barListView:rectTransform()
    local pos = tempRect.anchoredPosition
    pos.x = pos.x + 3
    tempRect.anchoredPosition = pos
  end
  self:Render(viewModelList,refreshFlag)
end

local function fixGroupObj(self,viewModelList,refreshFlag)
  if (self._scroll.verticalScrollbar~=nil) then
    self._scroll.verticalScrollbar.gameObject:SetActive(false)
    self._scroll.verticalScrollbar = nil
    local tempRect = self._barListView:rectTransform()
    local pos = tempRect.anchoredPosition
    pos.x = pos.x + 3
    tempRect.anchoredPosition = pos
  end
  self:Render(viewModelList,refreshFlag)
end

function MedalHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Medal.MedalShowBarListView)
  self:Fix_ex(CS.Torappu.UI.Medal.MedalShowBarListView, "Render", function(self,viewModelList,refreshFlag)
    local ok, ret , error = xpcall(fixUIObj,debug.traceback,self,viewModelList,refreshFlag)
    if not ok then
      eutil.LogError("[medal] fix" .. error)
    end
    return ret
  end)
  xlua.private_accessible(CS.Torappu.UI.Medal.MedalGroupListView)
  self:Fix_ex(CS.Torappu.UI.Medal.MedalGroupListView, "Render", function(self,viewModelList,refreshFlag)
    local ok, ret , error = xpcall(fixGroupObj,debug.traceback,self,viewModelList,refreshFlag)
    if not ok then
      eutil.LogError("[medal] fix" .. error)
    end
    return ret
  end)
end

function MedalHotfixer:OnDispose()
end

return MedalHotfixer