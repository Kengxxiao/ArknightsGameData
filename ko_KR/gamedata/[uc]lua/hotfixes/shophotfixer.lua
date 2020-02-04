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

  xutil.hotfix_ex(CS.Torappu.UI.Shop.ShopQCState, "OnQCInfoClick",
  function(self)
    xpcall(_QcConstImgHotfix, function(e)
      eutil.LogError(e)
    end,self)
    self:OnQCInfoClick()
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

function _QcConstImgHotfix(self)
  local hub = CS.Torappu.Lua.Util.GetComponent(CS.Torappu.UI.UIAssetLoader.LoadPrefab("[UC]Hotfix/qc_const_img_hub"), "SpriteHub")
  if hub == nil then
    eutil.LogError('[HOTFIX] qc_const_img_hub is missing')
    return
  end

  local isOk, newSprite = hub:TryGetSprite("qc_const_img")
  if isOk then
    local imgHolderGo = FindChildByPath(self.transform.parent, 'qc_detail_state/back_img/Image').gameObject
    local imgHolder = CS.Torappu.Lua.Util.GetComponent(imgHolderGo, "Image")
    imgHolder.sprite = newSprite
  end
end

function ShopHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Shop.ShopDetailCharView, "OpenCharacterShow", nil)
  xlua.hotfix(CS.Torappu.UI.Shop.ShopQCState, "OnQCInfoClick", nil)
end

return ShopHotfixer