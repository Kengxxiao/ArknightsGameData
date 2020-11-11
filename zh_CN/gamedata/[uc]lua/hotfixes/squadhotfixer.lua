-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local eutil = CS.Torappu.Lua.Util

---@class SquadHotfixer:HotfixBase
local SquadHotfixer = Class("SquadHotfixer", HotfixBase)

local function _CheckSkillAvalibale(charData, evolveState, level, skillIndex)
  local skills = charData.skills
  if skillIndex < 0 or skillIndex >= skills.Length then
    return false
  end
  return skills[skillIndex].initialUnlockCond:Validate(level, evolveState)
end

local function _PostRenderCard(cardPanel, sharedChar)
  if cardPanel == nil or sharedChar == nil then
    return
  end
  local skinId = sharedChar:GetSkinId()
  if skinId ~= "char_1001_amiya2#2" then
    return
  end
  local profHub = CS.Torappu.DataConvertUtil.LoadProfessionIconHub()
  if profHub == nil then
    return
  end
  local ok, sprite = profHub:TryGetSprite("icon_profession_warrior")
  if not ok then
    return
  end
  cardPanel._iconProfession.sprite = sprite
end

local function SquadAssistCard_RenderCard(self, sharedChar, evolvePhaseAndLevel, isFriend)
  self:_RenderCard(sharedChar, evolvePhaseAndLevel, isFriend)
  local ok = xpcall(_PostRenderCard, debug.traceback, self.m_characterCard, sharedChar)
end

function SquadHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.CharacterUtil)
  self:Fix_ex(CS.Torappu.CharacterUtil, "_CheckSkillAvalibale", _CheckSkillAvalibale)

  xlua.private_accessible(CS.Torappu.UI.UICharacterCardPanel)
  xlua.private_accessible(CS.Torappu.UI.Squad.SquadAssistCardView)
  self:Fix_ex(CS.Torappu.UI.Squad.SquadAssistCardView, "_RenderCard", SquadAssistCard_RenderCard)
end

function SquadHotfixer:OnDispose()
end

return SquadHotfixer