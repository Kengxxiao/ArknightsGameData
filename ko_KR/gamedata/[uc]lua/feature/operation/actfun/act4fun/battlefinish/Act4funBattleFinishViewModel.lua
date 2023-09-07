local luaUtils = CS.Torappu.Lua.Util
local rapidjson = require("rapidjson")

local Act4funLivePhotoCardDataNormal = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCardDataNormal"
local Act4funLivePhotoCardDataSpecial = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCardDataSpecial"














local Act4funBattleFinishViewModel = Class("Act4funBattleFinishViewModel");
Act4funBattleFinishViewModel.HEADICON_COUNT = 10;

function Act4funBattleFinishViewModel:InitData()
  local outPut = CS.Torappu.Battle.BattleInOut.instance.output;
  local finishResp = outPut.finishResponse;
  local playerData = CS.Torappu.PlayerData.instance.data.playerAprilFool

  if not finishResp then
    return
  end

  self.actData = CS.Torappu.ActivityDB.data.actFunData.act4FunData
  self.stageId = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.stageId;
  local mCount = finishResp.materials.Count;
  self.totalCount = mCount;
  self.specialCardList = {};
  self.cardList = {}; 
  local normalList = {};
  for idx = 1, mCount do
    local material = finishResp.materials[idx - 1];
    if material.materialType == 0 then
      table.insert(normalList, material);
    end
  end

  self.grandFlag = false
  if (self.actData.endingDict ~= nil) then
    for endingId, times in pairs(playerData.actFun4.liveEndings) do
      local suc, endingInfo = self.actData.endingDict:TryGetValue(endingId)
      if (suc and endingInfo.isGoodEnding) then
        self.grandFlag = true 
      end
    end
  end

  self.normalCard = nil;
  if #normalList > 0 then
    local normalMatId = normalList[1].materialId;
    local data = self:_GetNormalPhotoData(normalMatId);
    if data then
      self.normalCard = Act4funLivePhotoCardDataNormal.new();
      self.normalCard:Load(self.actData,data);
      self.normalCard:SetMat(normalList);
      table.insert(self.cardList, self.normalCard);
    end
  end

  for idx = 1, mCount do
    local material = finishResp.materials[idx - 1];
    if material.materialType ~= 0 then
      local spMatId = material.materialId;
      local data = self:_GetSpecialPhotoData(spMatId);
      if data then
        local photo = Act4funLivePhotoCardDataSpecial.new();
        photo:Load(self.actData,data);
        table.insert(self.specialCardList, photo);
        table.insert(self.cardList, photo);
      end
    end
  end

  self.nickText = self:_ReadRandomValueInTable(self.actData.randomMsgText);
  self.headiconList = {}
  local List_Int = CS.System.Collections.Generic.List(CS.System.Int32)
  local countList = List_Int()
  for idx = 0, self.actData.randomUserIconId.Count do
    countList:Add(idx)
  end
  for headiconIdx = 1, self.HEADICON_COUNT do
    local randomIndex=  RandomUtil.Range(1,countList.Count) - 1
    local index = countList[randomIndex]
    table.insert(self.headiconList,self.actData.randomUserIconId[index]);
    countList:RemoveAt(randomIndex)
  end
  self.isNewStage = self.stageId == self.actData.constant.studyStageId;
  self.ableToLive = false
  if self.isNewStage then
    self.detailText = self.actData.constant.spStageEndingTip;
  else
    if self.totalCount < self.actData.constant.liveMatAmtLowerLimit then
      self.detailText = self.actData.constant.noLiveEndingTip;
      return;
    end
    self.ableToLive = true
    if self.totalCount < self.actData.constant.liveTurnUpperLimit then
      self.detailText = self.actData.constant.notEnoughEndingTip;
      return;
    end
    self.detailText = self.actData.constant.enoughEndingTip;
  end
end


function Act4funBattleFinishViewModel:_ReadRandomValueInTable(Table)
  if Table == nil then
    return nil
  end
  return Table[RandomUtil.Range(1,Table.Count) - 1]
end



function Act4funBattleFinishViewModel:_GetNormalPhotoData(photoId)
  local suc, data = self.actData.normalMatDict:TryGetValue(photoId);
  if not suc then
    LogError("Can't find math data:" .. photoId);
    return nil;
  end
  return data;
end



function Act4funBattleFinishViewModel:_GetSpecialPhotoData(photoId)
  local suc, data = self.actData.spMatDict:TryGetValue(photoId);
  if not suc then
    LogError("Can't find special math data:" .. photoId);
    return nil;
  end
  return data;
end

return Act4funBattleFinishViewModel