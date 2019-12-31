local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class ShopHotfixer:HotfixBase
local ShopHotfixer = Class("ShopHotfixer", HotfixBase)

function ShopHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.Shop.ShopDetailCharView, "OpenCharacterShow",
  function(self)
    xpcall(ShopRepair, function(e)
      eutil.LogError(e)
    end,self)
  end)
end

function ShopRepair(self) 
  local showInfo = CS.Torappu.SharedCharData()
  showInfo.charId = self.m_charId
  showInfo.skillIndex = 0
  showInfo.mainSkillLvl = 1
  showInfo.level = 1
  local skill = CS.Torappu.SharedCharData.SharedCharSkillData()
  skill.skillId = CS.Torappu.DataConvertUtil.FindCharSkillIdByCharIdIndex(self.m_charId,0)
  skill.specializeLevel = 0
  showInfo.skills = {skill}
  local viewModel = CS.Torappu.UI.CharacterShowViewModel(showInfo)
  local param = CS.Torappu.UI.CharacterShow.CharacterShowPage.Params()
  param.viewModel = viewModel
  local option = CS.Torappu.UI.UIPageOption()
  option.args = param
  CS.Torappu.UI.UIPageController.OpenPage("character_show", option);
end

function ShopHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Shop.ShopDetailCharView, "OpenCharacterShow", nil)
end

return ShopHotfixer