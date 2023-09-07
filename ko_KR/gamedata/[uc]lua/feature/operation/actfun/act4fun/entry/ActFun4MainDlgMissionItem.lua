local luaUtils = CS.Torappu.Lua.Util;












local ActFun4MainDlgMissionItem = Class("ActFun4MainDlgMissionItem", UIPanel)


function ActFun4MainDlgMissionItem:Update(missionModel)
  if missionModel == nil or missionModel.missionData == nil or missionModel.playerMission == nil then
    return
  end
  local isFinished = missionModel.playerMission.finished and missionModel.playerMission.hasRecv
  SetGameObjectActive(self._panelFinished, isFinished)
  SetGameObjectActive(self._panelUnfinished, not isFinished)
  
  local txtColor = ''
  if isFinished then
    txtColor = self._colorFinish
  else
    txtColor = self._colorUnfinish
  end
  self._txtMission.text = luaUtils.Format(StringRes.ACTFUN_MISSION_DESC, txtColor, 
      missionModel.missionData.missionDes, missionModel.playerMission.value, missionModel.playerMission.target)
  local rewardIconIds = missionModel.missionData.rewardIconIds
  if rewardIconIds ~= nil and rewardIconIds.Count >= 2 then
    local reward1Sprite = self._atlasObject:GetSpriteByName(missionModel.missionData.rewardIconIds[0])
    self._imgReward1:SetSprite(reward1Sprite)
    local reward2Sprite = self._atlasObject:GetSpriteByName(missionModel.missionData.rewardIconIds[1])
    self._imgReward2:SetSprite(reward2Sprite)
  elseif rewardIconIds ~= nil and rewardIconIds.Count == 1 then
    local reward2Sprite = self._atlasObject:GetSpriteByName(missionModel.missionData.rewardIconIds[0])
    self._imgReward2:SetSprite(reward2Sprite)
  end
end

return ActFun4MainDlgMissionItem