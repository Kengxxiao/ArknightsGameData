
local luaUtils = CS.Torappu.Lua.Util;

















local ActFun4MainDigStageCard = Class("ActFun4MainDigStageCard", UIPanel)

function ActFun4MainDigStageCard:OnInit()
  self:AddButtonClickListener(self._btnCard, self.EventOnCardClick)
end

function ActFun4MainDigStageCard:Update(idx, stageModel)
  self.m_index = idx
  self.m_isUnlocked = stageModel.isUnlocked
  SetGameObjectActive(self._panelLocked, not self.m_isUnlocked)
  SetGameObjectActive(self._panelStageValid, self.m_isUnlocked)
  if self.m_isUnlocked then
    self._txtName.text = stageModel.stageData.name
    self._txtDesc.text = stageModel.description
    local codeSprite = self._atlasObject:GetSpriteByName(stageModel.stageId)
    self._imgCode:SetSprite(codeSprite)
    local iconSprite = self._atlasObject:GetSpriteByName(stageModel.valueIconId)
    self._imgIcon:SetSprite(iconSprite)
  end
end

function ActFun4MainDigStageCard:EventOnCardClick()
  if not self.m_isUnlocked then
    return
  end
  if self.evtClick then
    self.evtClick:Call(self.m_index);
  end  
end

return ActFun4MainDigStageCard