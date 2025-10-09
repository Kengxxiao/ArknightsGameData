local luaUtils = CS.Torappu.Lua.Util;










local RecruitOnlyItemModel = Class("RecruitOnlyItemModel");

function RecruitOnlyItemModel:LoadData(itemData, isPreview, playerUsedTime)
  if itemData == nil then
    return;
  end

  self.isUsed = (not isPreview) and (playerUsedTime >= itemData.tagTimes);
  self.isPhaseTwo = itemData.phaseNum > 1;
  self.upTimes = itemData.tagTimes;
  self.desc1 = itemData.desc1;
  self.desc2 = itemData.desc2;
  self.tagName = CS.Torappu.DataConvertUtil.FindGachaTagContentById(itemData.tagId);

  local useStartTimeDesc = itemData.startTime <= 0;
  if useStartTimeDesc then
    self.startTimeDesc = itemData.startTimeDesc;
  else 
    self.startTimeDesc = luaUtils.FormatDateTimeyyyyMMddHHmm(itemData.startTime);
  end

  local useEndTimeDesc = itemData.endTime <= 0;
  if useEndTimeDesc then
    self.endTimeDesc = itemData.endTimeDesc;
  else 
    self.endTimeDesc = luaUtils.FormatDateTimeyyyyMMddHHmm(itemData.endTime);
  end
end







local RecruitOnlyViewModel = Class("RecruitOnlyViewModel", UIViewModel);


function RecruitOnlyViewModel:LoadData(actId)
  if actId == nil then
    return
  end
  self.m_actId = actId;

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_actId);
  if not suc then
    return;
  end

  local suc, actData = CS.Torappu.ActivityDB.data.activity.recruitOnlyData:TryGetValue(self.m_actId);
  if not suc then
    return;
  end

  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.recruitOnlyList:TryGetValue(self.m_actId);
  if not suc then
    return;
  end
  local playerUsedTime = playerActData.used;

  if actData.recruitData ~= nil then
    self.recruitModel = RecruitOnlyItemModel.new();
    self.recruitModel:LoadData(actData.recruitData, false, playerUsedTime);
  end

  if actData.previewData ~= nil then
    self.previewModel = RecruitOnlyItemModel.new();
    self.previewModel:LoadData(actData.previewData, true, playerUsedTime);
  end
end

return RecruitOnlyViewModel

