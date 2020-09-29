---@class SkinSelectHotfixer:HotfixBase

local eutil = CS.Torappu.Lua.Util
local uiUtil = CS.Torappu.Lua.LuaUIUtil
local SkinSelectHotfixer = Class("SkinSelectHotfixer", HotfixBase)
-- 未持有
local OWN_STRING_CN = "未持有"

local OWN_STRING_EN = "Obtained"
local OWN_STRING_KR = "보유 중"
local OWN_STRING_JP = "所持中"


local function SkinSelectTextFix(self)

  local obj = uiUtil.GetChild(self.gameObject, "left_part/down_container/have_no_char_state")

  -- second child with text 
  local targetText = obj:GetComponentsInChildren(typeof(CS.UnityEngine.UI.Text))[1]

  local isJp = CS.Torappu.I18N.LocalizationEnv.IsJapan()
  local isKr = CS.Torappu.I18N.LocalizationEnv.IsKorea()
  local isEn = CS.Torappu.I18N.LocalizationEnv.IsEnArea()

  if isJp then
    targetText.text = OWN_STRING_JP
  elseif isKr then
    targetText.text = OWN_STRING_KR
  elseif isEn then
    targetText.text = OWN_STRING_EN
  end
  
end




function SkinSelectHotfixer:OnInit()
    self:Fix_ex(CS.Torappu.UI.Skin.SkinSelectState, "OnEnter",function(self)
      self:OnEnter()
      local ok, error = xpcall(SkinSelectTextFix, debug.traceback, self)
      if not ok then 
        eutil.LogError("[SkinSelectHotfixer] fix error:" .. error)
      end
    end)

    
end

function SkinSelectHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Skin.SkinSelectState,"OnEnter", nil)
end

return SkinSelectHotfixer