local luaUtils = CS.Torappu.Lua.Util
local CommonCharCardView = CS.Torappu.UI.CommonCharCardView
local CommonCharCardViewModel = CS.Torappu.UI.CommonCharCardViewModel

local CommonCharCardCacheHotfixer = Class("CommonCharCardCacheHotfixer", HotfixBase)

local function _CheckCacheConditionFix(self, cardAssets, characterCardViewModel, cardPlugin)
  if cardAssets == nil or characterCardViewModel == nil or cardPlugin == nil then
    return
  end
  cardPlugin:RendView(cardAssets, characterCardViewModel)
end

local function _FillViewModelFix(self, playerCharacter, skillId, equipId, instAble)
  self:FillViewModel(playerCharacter, skillId, equipId, instAble)
  if skillId ~= nil and skillId ~= "" then
    self.skillId = skillId
  else
    self.skillId = ""
    local playerSkills = playerCharacter:GetCurSkills()
    if playerSkills == nil then
      return
    end
    local skillIndex = playerCharacter:GetDefaultSkillIndex()
    if skillIndex < 0 or playerSkills.Length < skillIndex then
      return
    end
    local newSkill = playerSkills[skillIndex]
    if newSkill == nil then
      return
    end
    self.skillId = newSkill.skillId
  end
end

function CommonCharCardCacheHotfixer:OnInit()
  xlua.private_accessible(typeof(CommonCharCardView))
  self:Fix_ex(CommonCharCardView, "_RendCardSingleTypeView", function(self, cardAssets, characterCardViewModel, cardPlugin)
    local ok, errorInfo = xpcall(_CheckCacheConditionFix, debug.traceback, self, cardAssets, characterCardViewModel, cardPlugin)
    if not ok then
      LogError("[common char card] CommonCharCardView fix error: " .. errorInfo)
    end
  end)

  xlua.private_accessible(typeof(CommonCharCardViewModel))
  self:Fix_ex(CommonCharCardViewModel, "FillViewModel", function(self, playerCharacter, skillId, equipId, instAble)
    local ok, errorInfo = xpcall(_FillViewModelFix, debug.traceback, self, playerCharacter, skillId, equipId, instAble)
    if not ok then
      LogError("[common char card] CommonCharCardViewModel fix error: " .. errorInfo)
    end
  end)
end

return CommonCharCardCacheHotfixer