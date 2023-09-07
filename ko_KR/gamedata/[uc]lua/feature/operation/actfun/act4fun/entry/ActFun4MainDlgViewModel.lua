local luaUtils = CS.Torappu.Lua.Util;







local ActFun4MainDlgTokenModel = Class("ActFun4MainDlgTokenModel")
function ActFun4MainDlgTokenModel:IsLevelMax()
  return self.level == self.levelCount
end






local ActFun4MainDlgMissionModel = Class("ActFun4MainDlgMissionModel")










local ActFun4MainDlgStageModel = Class("ActFun4MainDlgStageModel")















ActFun4MainDlgViewModel = Class("ActFun4MainDlgViewModel", UIViewModel)

function ActFun4MainDlgViewModel:LoadData(charId, stageIds)
  self.gameData = CS.Torappu.ActivityDB.data.actFunData.act4FunData
  if self.gameData == nil then
    return
  end
  self.m_charId = charId
  self.m_stageIds = stageIds
  self:_UpdateByPlayerData()
end

function ActFun4MainDlgViewModel:RefreshData()
  self:_UpdateByPlayerData()
end

function ActFun4MainDlgViewModel:CheckNeedShowV()
  local playerEndings = self.playerData.actFun4.liveEndings
  local endingDict = self.gameData.endingDict

  if endingDict == nil then
    return false
  end
  for endingId, times in pairs(playerEndings) do
    local suc, endingInfo = endingDict:TryGetValue(endingId)
    if suc and endingInfo.isGoodEnding then
      return true
    end
  end
  return false
end

function ActFun4MainDlgViewModel:CheckDiamondGot()
  local missionId = self.gameData.constant.mainPageDiamondMissionId
  if missionId == nil then
    return false
  end
  local suc, missionInfo = self.playerData.actFun4.missions:TryGetValue(missionId)
  if suc and missionInfo.hasRecv then
    return true
  end
  return false
end

function ActFun4MainDlgViewModel:CheckGotChar()
  return self.m_charId ~= nil and self.playerChar ~= nil
end

function ActFun4MainDlgViewModel:IsStagePassed(stageModel)
  return stageModel.state == CS.Torappu.PlayerStageState.PASS or stageModel.state == CS.Torappu.PlayerStageState.COMPLETE
end

function ActFun4MainDlgViewModel:_UpdateByPlayerData()
  self.playerData = CS.Torappu.PlayerData.instance.data.playerAprilFool
  self.playerChar = CS.Torappu.PlayerData.instance:GetCharInstById(self.m_charId)
  self:_UpdateTokenModelByPlayerData()
  self:_UpdateMissionInfoByPlayerData()
  self:_UpdateStageInfoByPlayerData()
end

function ActFun4MainDlgViewModel:_UpdateTokenModelByPlayerData()
  local tokenLevelInfos = self.gameData.tokenLevelInfos
  if self.tokenModel == nil then
    self.tokenModel = ActFun4MainDlgTokenModel.new()
  end
  self.tokenModel.level = self.playerData.actFun4.tokenLevel
  self.tokenModel.levelDescs = {}
  self.tokenModel.tokenDesc = ''
  self.tokenModel.levelCount = tokenLevelInfos.Count
  for levelId, levelInfo in pairs(tokenLevelInfos) do
    local tokenLevelNum = levelInfo.tokenLevelNum
    if self.tokenModel.level == tokenLevelNum then
      self.tokenModel.tokenDesc = levelInfo.skillDesc
    end
    if levelInfo.levelDesc ~= nil and levelInfo.levelDesc ~= '' then
      table.insert(self.tokenModel.levelDescs, levelInfo.levelDesc)
    end
  end
end

function ActFun4MainDlgViewModel:_UpdateMissionInfoByPlayerData()
  self.finishedMissionCount = 0
  self.totalMissionCount = 0
  self.missionModels = {}
  self.curRewardMissionModel = nil
  for missionId, playerMission in pairs(self.playerData.actFun4.missions) do
    local suc, missionData = self.gameData.missionDatas:TryGetValue(missionId)
    if suc then
      local missionModel = ActFun4MainDlgMissionModel.new()
      missionModel.missionId = missionId
      missionModel.missionData = missionData
      missionModel.playerMission = playerMission
      if self.curRewardMissionModel == nil and playerMission.finished and not playerMission.hasRecv then
        self.curRewardMissionModel = missionModel
      end
      if playerMission.finished and playerMission.hasRecv then
        self.finishedMissionCount = self.finishedMissionCount + 1
      end
      self.totalMissionCount = self.totalMissionCount + 1
      table.insert(self.missionModels, missionModel)
    end
  end
end

function ActFun4MainDlgViewModel:_UpdateStageInfoByPlayerData()
  self.studyStageModel = nil
  self.stageModels = {}
  local studyStageId = self.gameData.constant.studyStageId
  self.studyStageModel = self:_CreateStageModel(studyStageId)
  self.studyStageModel.isUnlocked = true
  
  local isStudyPassed = self:IsStagePassed(self.studyStageModel)
  for i = 1, #self.m_stageIds do
    local stageModel = nil
    if not isStudyPassed then
      stageModel = ActFun4MainDlgStageModel.new()
      stageModel.isUnlocked = false
    else
      stageModel = self:_CreateStageModel(self.m_stageIds[i])
      stageModel.isUnlocked = true
    end
    table.insert(self.stageModels, stageModel)
  end
end

function ActFun4MainDlgViewModel:_CreateStageModel(stageId)
  local suc1, stageData = CS.Torappu.ActivityDB.data.actFunData.stages:TryGetValue(stageId)
  if not suc1 then
    return nil
  end
  local stageModel = ActFun4MainDlgStageModel.new()
  stageModel.stageId = stageId
  stageModel.stageData = stageData
  local suc2, stageExtraData = self.gameData.stageExtraDatas:TryGetValue(stageId)
  if suc2 then
    stageModel.description = stageExtraData.description
    stageModel.valueIconId = stageExtraData.valueIconId
  end
  stageModel.state = CS.Torappu.PlayerStageState.UNLOCKED
  local suc3, playerStage = self.playerData.actFun4.stages:TryGetValue(stageId)
  if suc3 then
    stageModel.state = playerStage.state
    stageModel.times = playerStage.liveTimes
  end
  return stageModel
end