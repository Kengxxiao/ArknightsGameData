local luaUtils = CS.Torappu.Lua.Util;






local Act4funCommentItemModel = Class("Act4funCommentItemModel");










local Act4funCommentGroupModel = Class("Act4funCommentGroupModel");


local function _Shuffle(lst)
  if lst == nil or #lst == 0 then
    return;
  end
  local length = #lst;
  for i = 1, length do
    local swapI = RandomUtil.Range(i, length);

    local temp = lst[i];
    lst[i] = lst[swapI];
    lst[swapI] = temp;
  end
end


function Act4funCommentGroupModel:LoadData(performId)
  self.specialCommentList = {};
  self.normalCommentList = {};

  self.m_currSpecialCommentIdx = 1;

  local data = CS.Torappu.ActivityDB.data.actFunData.act4FunData;
  if data == nil or performId == nil then
    return;
  end
  self.minDelayTime = data.constant.cmtAppearTimeLowerLimit;
  self.maxDelayTime = data.constant.cmtAppearTimeUpperLimit;
  local defaultIconId = data.constant.liveMatDefaultUserIcon;

  local suc, performInfo = data.performInfoDict:TryGetValue(performId);
  if not suc then
    return;
  end

  local specialCommentId = performInfo.fixedCmpGroup;
  if specialCommentId ~= nil and specialCommentId ~= "" then
    local suc, commentInfo = data.cmtGroupInfoDict:TryGetValue(specialCommentId);
    if suc then
      self:_LoadCommentData(self.specialCommentList, commentInfo, data.cmtUsers, defaultIconId);
    end
  end
  _Shuffle(self.specialCommentList);

  for i = 0, performInfo.cmpGroups.Count - 1 do
    local commentGrpId = performInfo.cmpGroups[i];
    if commentGrpId ~= nil and commentGrpId ~= "" then
      local suc, commentInfo = data.cmtGroupInfoDict:TryGetValue(commentGrpId);
      if suc then
        self:_LoadCommentData(self.normalCommentList, commentInfo, data.cmtUsers, defaultIconId);
      end
    end
  end
end


function Act4funCommentGroupModel:NextComment()
  if self.normalCommentList == nil or self.specialCommentList == nil then
    return nil;
  end
  if self.m_currSpecialCommentIdx < #self.specialCommentList then
    local model = self.specialCommentList[self.m_currSpecialCommentIdx];
    self.m_currSpecialCommentIdx = self.m_currSpecialCommentIdx + 1;
    return model;
  end
  local normalCommentCount = #self.normalCommentList;
  if normalCommentCount <= 0 then
    return nil;
  end
  local index = RandomUtil.Range(1, normalCommentCount);
  return self.normalCommentList[index];
end





function Act4funCommentGroupModel:_LoadCommentData(lst, commentInfo, userList, defaultIconId)
  if commentInfo == nil or commentInfo.cmtList == nil or userList == nil then
    return;
  end
  local userCount = userList.Count - 1;
  for i = 0, commentInfo.cmtList.Count - 1 do
    local item = commentInfo.cmtList[i];
    local commentModel = Act4funCommentItemModel.new();
    commentModel.iconId = item.iconId;
    commentModel.name = item.name;
    commentModel.desc = item.cmtTxt;
    if commentModel.name == nil or commentModel.name == "" then
      local randomUserIndex = RandomUtil.Range(0, userCount);
      commentModel.name = userList[randomUserIndex];
    end
    if commentModel.iconId == nil or commentModel.iconId == "" then
      commentModel.iconId = defaultIconId;
    end
    table.insert(lst, commentModel);
  end
end







local Act4funLivePerform = Class("Act4funLivePerform");


function Act4funLivePerform:LoadData(performData)
  self.data = performData;
  self.wordCount = 0;
  if self.data ~= nil and self.data.words ~= nil then
    self.wordCount = self.data.words.Count;
    self.commentModel = Act4funCommentGroupModel.new();
    self.commentModel:LoadData(self.data.performId);
  end
  self.currWordIdx = -1;
  if self.wordCount <= 0 then
    LogWarning("words of perform is empty!");
  end
end

function Act4funLivePerform:IsComplete()
  return self.currWordIdx >= self.wordCount;
end


function Act4funLivePerform:NextWord()
  self.currWordIdx = self.currWordIdx + 1;
  local cnt = self.data.words.Count;
  if self.currWordIdx < 0 or self.currWordIdx >= cnt then
    return nil;
  end
  return self.data.words[self.currWordIdx];
end

local Act4funLivePhotoCardDataNormal = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCardDataNormal"
local Act4funLivePhotoCardDataSpecial = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCardDataSpecial"
local Act4funLiveValueModel = require "Feature/Operation/ActFun/Act4fun/ViewModel/Act4funLiveValueModel"












local Act4funScItemModel = Class("Act4funScItemModel");


function Act4funScItemModel:LoadData(data)
  if data == nil then
    return;
  end
  self.id = data.superChatId;
  self.userName = data.userName;
  self.userIcon = data.iconId;
  self.effectId = data.valueEffectId;
  self.performId = data.performId;
  self.desc = data.superChatTxt;
  self.isClicked = false;
end






local Act4funScModel = Class("Act4funScModel");

function Act4funScModel:LoadData()
  self.normalScModelList = {};
  self.relatedScModelDict = {};
  self.m_normalBegin = 0;

  local data = CS.Torappu.ActivityDB.data.actFunData.act4FunData;
  if data == nil then
    return;
  end
  local countDownTime = data.constant.superChatCountDownNum;

  local spMatDict = {};
  for matId, itemData in pairs(data.spMatDict) do
    if itemData.accordingSuperChatId ~= nil and itemData.accordingSuperChatId ~= "" then
      spMatDict[itemData.accordingSuperChatId] = matId;
    end
  end
  
  for id, scData in pairs(data.superChatInfoDict) do
    if scData.chatType == CS.Torappu.Act4funSuperChatType.ROLLED then
      local model = Act4funScItemModel.new();
      model:LoadData(scData);
      model.countDownTime = countDownTime;
      table.insert(self.normalScModelList, model);
    elseif scData.chatType == CS.Torappu.Act4funSuperChatType.RELATED then
      local relatedMatId = spMatDict[id];
      if relatedMatId == nil then
        luaUtils.LogError("[Act4funScModel] Cannot find related mat of sc : "..id);
      else
        local model = Act4funScItemModel.new();
        model:LoadData(scData);
        model.countDownTime = countDownTime;
        self.relatedScModelDict[relatedMatId] = model;
      end
    end
  end
end

function Act4funScModel:ResetStatus()
  for id, scData in pairs(self.relatedScModelDict) do
    scData.isClicked = false;
  end
  for index, scData in pairs(self.normalScModelList) do
    scData.isClicked = false;
  end
end



function Act4funScModel:GetScModel(matId)
  if self.relatedScModelDict == nil or self.normalScModelList == nil then
    return nil;
  end
  local relatedSc = self.relatedScModelDict[matId];
  if relatedSc ~= nil then
    return relatedSc;
  end
  local normalScCount = #self.normalScModelList;
  local unusedScCount = normalScCount - self.m_normalBegin;
  if unusedScCount <= 0 then
    return nil;
  end
  self.m_normalBegin = self.m_normalBegin + 1;
  local randomIdx = RandomUtil.Range(self.m_normalBegin, normalScCount);
  local currUseSc = self.normalScModelList[randomIdx];
  self.normalScModelList[randomIdx] = self.normalScModelList[self.m_normalBegin];
  self.normalScModelList[self.m_normalBegin] = currUseSc;
  return currUseSc;
end


Act4funLiveStep = {
  
  NONE = "NONE",
  
  ONLINE = "ONLINE", 
  
  INTRODUCE = "INTRODUCE", 
  
  NEED_PHOTO = "NEED_PHOTO", 
  
  NO_PHOTO = "NO_PHOTO", 
  
  WAIT_PHOTO = "WAIT_PHOTO", 
  
  PHOTO_USE_ANIM = "PHOTO_USE_ANIM",
  
  PHOTO_PERFORM = "PHOTO_PERFORM", 
  
  SC_PERFORM = "SC_PERFORM", 
  
  VALUE_SETTLE = "VALUE_SETTLE", 
  
  TURN_UPDATE = "TURN_UPDATE",
  
  REQ_LIVE_END = "REQ_LIVE_END",
  
  LIVE_END = "LIVE_END",
  
  OFFLINE = "OFFLINE", 
}
Readonly(Act4funLiveStep);















Act4funLiveData = Class("Act4funLiveData", UIViewModel)
Act4funLiveData.VALUE1_ID = "liveValue_1";
Act4funLiveData.VALUE2_ID = "liveValue_2";
Act4funLiveData.VALUE3_ID = "liveValue_3";
Act4funLiveData.VALUE_ID_LIST = {Act4funLiveData.VALUE1_ID, Act4funLiveData.VALUE2_ID, Act4funLiveData.VALUE3_ID};
Act4funLiveData.NO_COMMENTS_STEPS = { Act4funLiveStep.NONE, Act4funLiveStep.WAIT_PHOTO, Act4funLiveStep.PHOTO_USE_ANIM,
Act4funLiveStep.REQ_LIVE_END, Act4funLiveStep.LIVE_END, Act4funLiveStep.OFFLINE };


function Act4funLiveData:Load(playerData)
  self.photos = {}

  self.actData = CS.Torappu.ActivityDB.data.actFunData.act4FunData
  if not self.actData then
    self:_ErrorData("Can't find the act4fun data");
    return;
  end

  local respData = playerData.resp;

  self.liveId = respData.liveId;
  self:_SetStep(Act4funLiveStep.ONLINE );
  self.currTurn = 0;
  self.maxTurn = self.actData.constant.liveTurnUpperLimit;
  self.valueModel = Act4funLiveValueModel.new();
  self.valueModel:Init(self.actData);

  self.scGroupModel = Act4funScModel.new();
  self.scGroupModel:LoadData();

  self.m_process = {}

  local normalCardDic = {}

  for _, mat in ipairs(respData.materials) do
    if mat.materialType == 0 then
      
      local photo = normalCardDic[mat.materialId];
      if photo then
        photo:CollectMaterial(mat);
      else
        local data = self:_GetNormalPhotoData(mat.materialId);
        if data then
          local photo = Act4funLivePhotoCardDataNormal.new();
          photo:Load(self.actData, data);
          photo:CollectMaterial(mat);
          table.insert(self.photos, photo);
          normalCardDic[mat.materialId] = photo;
        else
          LogError("Can't find photo data:"..mat.materialId);
        end
      end
    elseif mat.materialType == 1 then
      local data = self:_GetSpecialPhotoData(mat.materialId);
      if data then
        local photo = Act4funLivePhotoCardDataSpecial.new();
        photo:Load(self.actData, data, mat);
        table.insert(self.photos, photo);
      else
        LogError("Can't find special photo data:"..mat.materialId);
      end
    end
  end

  table.sort(self.photos, function(a, b)
    if a:IsSpecial() == b:IsSpecial() then
      local aId = a:GetID();
      local bId = b:GetID();
      return aId < bId;
    end
    if a:IsSpecial() then
      return false;
    end
    return true;
  end);
end

function Act4funLiveData:_SetStep(step)
  self.currStep = step;
  if self.currPerform then
    local idx = FindIndex(Act4funLiveData.NO_COMMENTS_STEPS, step);
    self.currPerform.commentModel.playing = idx == -1;
  end
  self:NotifyUpdate();
end

function Act4funLiveData:GetLiveProcess()
  return self.m_process;
end


function Act4funLiveData:InPerform()
  return self.currPerform ~= nil and not self.currPerform:IsComplete();
end

function Act4funLiveData:CompleteOnline()
  if self.currStep ~= Act4funLiveStep.ONLINE then
    return;
  end
  local introducePerformGrp = self.actData.constant.openingPerformGroup;
  self:_ResetCurrentPerformByGrp(introducePerformGrp);
  self:_SetStep(Act4funLiveStep.INTRODUCE );
end


function Act4funLiveData:_EnterNeedPhotoStep()
  local forgetPerformGroup = self.actData.constant.forgetPerformGroup;
  self:_ResetCurrentPerformByGrp(forgetPerformGroup);
  self:_SetStep(Act4funLiveStep.NEED_PHOTO);
end


function Act4funLiveData:SetupOffline()
  self:_SetStep(Act4funLiveStep.OFFLINE);
end

function Act4funLiveData:CompletePerform()
  if self.currStep == Act4funLiveStep.INTRODUCE then
    self:_EnterNeedPhotoStep();
    return;
  end

  if self.currStep == Act4funLiveStep.NEED_PHOTO then
    local photoCnt = #self.photos;
    if photoCnt > 0 then
      self:_SetStep(Act4funLiveStep.WAIT_PHOTO);
      return;
    end
    local noPhotoPerformGrp = self.actData.constant.runPerformGroup;
    self:_ResetCurrentPerformByGrp(noPhotoPerformGrp);
    self:_SetStep(Act4funLiveStep.NO_PHOTO);
    return;
  end

  if self.currStep == Act4funLiveStep.PHOTO_PERFORM then
    self.valueModel:SettlePhoto(self.usingPhoto);
    self:_SetStep(Act4funLiveStep.VALUE_SETTLE);
    return;
  end

  if self.currStep == Act4funLiveStep.SC_PERFORM then
    self.scGroupModel:ResetStatus();
    self.valueModel:SettleSC(self.currSc, self.actData);
    self:_SetStep(Act4funLiveStep.VALUE_SETTLE);
    return;
  end

  if self.currStep == Act4funLiveStep.NO_PHOTO then
    return self:SetupOffline();
  end
end

function Act4funLiveData:SelectPhoto(idx)
  local photo = self.photos[idx];
  if not photo then
    return;
  end
  local performId = photo:GetSelectPerform();
  if performId == nil or performId == "" then
    return;
  end
  
  self:_ResetCurrentPerformById(performId);
  self:NotifyUpdate();
end

function Act4funLiveData:UsePhoto(idx)
  if self.currStep ~= Act4funLiveStep.WAIT_PHOTO then
    return false;
  end

  local photo = self.photos[idx];
  if not photo then
    return false;
  end
  local suc = photo:UseOne();
  if suc then
    if photo:GetCount() <= 0 then
      table.remove(self.photos, idx);
    end
    self.usingPhoto = photo;
    self:_SetStep(Act4funLiveStep.PHOTO_USE_ANIM);
    return true;
  end
  return false;
end

function Act4funLiveData:NeedShowPhotoPanel()
  return self.currStep == Act4funLiveStep.WAIT_PHOTO 
  or self.currStep == Act4funLiveStep.PHOTO_USE_ANIM
  or self.currStep == Act4funLiveStep.NO_PHOTO;
end

function Act4funLiveData:CanSelectPhoto()
  return self.currStep == Act4funLiveStep.WAIT_PHOTO;
end

function Act4funLiveData:ExecutePhoto()
  if not self.usingPhoto then
    return false;
  end
  
  local suc = false;
  if self.usingPhoto:IsSpecial() then
    local performId = self.usingPhoto:GetPerformId();
    suc = self:_ResetCurrentPerformById(performId);
  else
    local performGrpId = self.usingPhoto:GetPerformGrpId();
    suc = self:_ResetCurrentPerformByGrp(performGrpId);
  end
  local matId = self.usingPhoto:GetID();
  local newSc = self.scGroupModel:GetScModel(matId);
  if newSc then
    self.currSc = newSc;
  end

  if not suc then
    self:_ErrorData("setup photo perform failed!"..self.usingPhoto:GetID());
    return;
  end
  self:_SetStep(Act4funLiveStep.PHOTO_PERFORM);
  return true;
end

function Act4funLiveData:CompleteValueSettle()
  local valueBreak = self.valueModel:HasValueBreak();
  if valueBreak then
    self:_RecordCurrTurn();
    self:_SetStep(Act4funLiveStep.REQ_LIVE_END);
    return;
  end

  local scPerform = self.currSc ~= nil and self.currSc.isClicked;
  if scPerform then
    self:_ResetCurrentPerformById(self.currSc.performId);
    self:_SetStep(Act4funLiveStep.SC_PERFORM);
    return;
  end

  self:_RecordCurrTurn();
  self.currTurn = self.currTurn + 1;
  self:_SetStep(Act4funLiveStep.TURN_UPDATE);
end

function Act4funLiveData:CompleteTurnUpdate()
  if self.currTurn >= self.maxTurn then
    self:_SetStep(Act4funLiveStep.REQ_LIVE_END);
    return;
  end
  self:_EnterNeedPhotoStep();
end

function Act4funLiveData:CompleteReqEnd(endingId)
  local suc, endData = self.actData.endingDict:TryGetValue(endingId);
  if not suc then
    LogError("Can't find ending data:"..endingId);
  end

  self.liveEnding = endData;
  self:_SetStep(Act4funLiveStep.LIVE_END);
end

function Act4funLiveData:_RecordCurrTurn()
  
  local usingPhoto = self.usingPhoto;
  local proc = {
    instId = usingPhoto:GetUsingInstId(), 
  }
  if self.currSc ~= nil and self.currSc.isClicked then
    proc.sc = self.currSc.id;
  end
  table.insert(self.m_process, proc);
end


function Act4funLiveData:_GetPerformFromGroup(performGrpId)
  local suc, grpInfo = self.actData.performGroupInfoDict:TryGetValue(performGrpId);
  if not suc then
    LogError("Can't find the perform group:" .. performGrpId);
    return nil;
  end
  local performIds = grpInfo.performIds;
  local cnt = performIds.Count;
  local randomIdx = RandomUtil.Range(0, cnt-1);
  local performId = performIds[randomIdx];
  return self:_GetPerformById(performId);
end


function Act4funLiveData:_GetPerformById(performId)
  local suc, performInfo = self.actData.performInfoDict:TryGetValue(performId);
  if not suc then
    LogError("Can't find the perform:" .. performId);
    return nil;
  end
  return performInfo;
end


function Act4funLiveData:_ResetCurrentPerformByGrp(performGrpId)
  if performGrpId == nil or performGrpId == "" then
    return false;
  end

  local performData = self:_GetPerformFromGroup(performGrpId);
  if not performData then
    self:_ErrorData("performData can't be nil!");
    return false;
  end
  self:_ResetCurrentPerform(performData);
  return true;
end

function Act4funLiveData:_ResetCurrentPerformById(performId)
  if performId == nil or performId == "" then
    return false;
  end

  local performData = self:_GetPerformById(performId);
  if not performData then
    return false;
  end
  self:_ResetCurrentPerform(performData);
  return true;
end


function Act4funLiveData:_ResetCurrentPerform(perfromData)
  if not self.currPerform then
    self.currPerform = Act4funLivePerform.new();
  end
  self.currPerform:LoadData(perfromData);
end



function Act4funLiveData:_GetNormalPhotoData(photoId)
  local suc, data = self.actData.normalMatDict:TryGetValue(photoId);
  if not suc then
    LogError("Can't find math data:" .. photoId);
    return nil;
  end
  return data;
end



function Act4funLiveData:_GetSpecialPhotoData(photoId)
  local suc, data = self.actData.spMatDict:TryGetValue(photoId);
  if not suc then
    LogError("Can't find special math data:" .. photoId);
    return nil;
  end
  return data;
end


function Act4funLiveData:_ErrorData(message)
  LogError(message);
  self:_SetStep(Act4funLiveStep.NONE);
  
end