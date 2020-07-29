local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class RecruitAvailDetailObjHotfixer:HotfixBase
local RecruitAvailDetailObjHotfixer = Class("RecruitAvailDetailObjHotfixer", HotfixBase)

local nian_limit_hint_content = "This rate changes based upon the number of Headhunting rolls.For more details, see <color=#00C8FF>[Limited Headhunting]</color> below."
local nian_char_id = "char_2014_nian"

local function LocalFixFunc(self,perObj)
    if perObj ~= nil then
      local charIdList = perObj.charIdList
      if charIdList ~= nil then
        for i = 0,charIdList.Count -1 do
          if(charIdList[i] == nian_char_id) then
            local text_obj = CS.Torappu.Lua.LuaUIUtil.GetChild(self._holder6StarHint, "const_text")
            if text_obj ~= nil then
              text_obj:GetComponent("Text").text = nian_limit_hint_content
            end
            break
          end
        end
      end
    end
end

function RecruitAvailDetailObjHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.Recruit.RecruitAvailDetailObj, "Render",
  function(self, perObj, isEnd, showRecruit6StarHint)
    self:Render(perObj, isEnd, showRecruit6StarHint)
    xpcall(LocalFixFunc, function(e)
      eutil.LogError(e)
    end, self,perObj)
  end)
end

function RecruitAvailDetailObjHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Recruit.RecruitAvailDetailObj, "Render", nil)
end

return RecruitAvailDetailObjHotfixer