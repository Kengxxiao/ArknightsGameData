local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class RecruitUpCharDetailPortraitObjHotfixer:HotfixBase
local RecruitUpCharDetailPortraitObjHotfixer = Class("RecruitUpCharDetailPortraitObjHotfixer", HotfixBase)

local function LocalFixFunc(self)
  local target = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject, "char_name")
  local target_text = target:GetComponent("Text")
  local target_rect = target:GetComponent("RectTransform")
  target_text.resizeTextForBestFit = true
  target_text.resizeTextMaxSize = 18
  target_rect.sizeDelta = CS.UnityEngine.Vector2(100, target_rect.sizeDelta.y)
end

function RecruitUpCharDetailPortraitObjHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.Recruit.RecruitUpCharDetailPortraitObj, "Render",
  function(self, charId, isLimit)
    xpcall(LocalFixFunc, function(e)
      eutil.LogError(e)
    end, self)
    self:Render(charId, isLimit)
  end)
end

function RecruitUpCharDetailPortraitObjHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Recruit.RecruitUpCharDetailPortraitObj, "Render", nil)
end

return RecruitUpCharDetailPortraitObjHotfixer