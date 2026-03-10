local luaUtils = CS.Torappu.Lua.Util;
local dateUtil = CS.Torappu.DateTimeUtil;

local ReturnAllOpenType = CS.Torappu.ReturnAllOpenType;
local EnumInfoCache = CS.Torappu.EnumInfoCache(ReturnAllOpenType)













local ReturnSpecialOpenTypeModel = Class("ReturnSpecialOpenTypeModel");

function ReturnSpecialOpenTypeModel:ctor()
  self.specialOpenType = ReturnAllOpenType.RESOURCE;
  self.openState = ReturnSpecialOpenState.END;
  self.remainTimeDesc = "";
  self.name = "";
  self.title = "";
  self.pauseDesc = "";
  self.desc = "";
  self.imgBkgId = "";
  self.imgIconId = "";
  self.imgEntryId = "";
end


function ReturnSpecialOpenTypeModel:LoadData(openData)
  self.specialOpenType = openData.allOpenType;
  self.desc = openData.desc;

  local gameData = ReturnModel.me:GetGameData();
  if gameData == nil or gameData.openStyleData == nil then
    return;
  end

  local typeStr = EnumInfoCache.ConvertToString(self.specialOpenType);
  local ok, styleData = gameData.openStyleData:TryGetValue(typeStr);

  if not ok or styleData == nil then
    return;
  end

  self.title = styleData.title;
  self.name = styleData.name;
  self.pauseDesc = styleData.pauseDesc;
  self.imgBkgId = styleData.imgBkgId;
  self.imgIconId = styleData.imgIconId;
  self.imgEntryId = styleData.imgEntryId;
  self.m_sortId = styleData.sortId;
end


function ReturnSpecialOpenTypeModel:RefreshPlayerData(playerData)
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end

  if self.specialOpenType == ReturnAllOpenType.RESOURCE then
    self.openState = ReturnModel.me:CheckWeeklyFullOpenState(playerData.currentV2);
    self.remainTimeDesc = self:_GetTimeText(ReturnModel.me:GetWeeklyFullOpenRemainDay(playerData.currentV2), self.openState);
  elseif self.specialOpenType == ReturnAllOpenType.CAMP then
    self.openState = ReturnModel.me:CheckCampFullOpenState(playerData.currentV2);
    self.remainTimeDesc = self:_GetTimeText(ReturnModel.me:GetCampFullOpenRemainDay(playerData.currentV2), self.openState);
  end
end



function ReturnSpecialOpenTypeModel:_GetSpecialOpenRemainDesc(playerData)
  if playerData == nil or playerData.currentV2 == nil or
      playerData.currentV2.fullOpen == nil then
    return "";
  end

  local fullOpen = playerData.currentV2.fullOpen;
  local isTodayFullOpen = fullOpen.today;
  local fullOpenRemain = fullOpen.remain;

  if isTodayFullOpen == nil or fullOpenRemain == nil then
    return "";
  end

  local timeStr = "";
  local daysTextFormat = StringRes.DAY_TEXT;
  if not isTodayFullOpen then
    
    timeStr = luaUtils.Format(daysTextFormat, fullOpenRemain);
  else
    
    
    if fullOpenRemain > 1 then
      timeStr = luaUtils.Format(daysTextFormat, fullOpenRemain);
    else
      
      local currentTime = dateUtil.currentTime;
      local nextCrossDayTime = dateUtil.GetCurrentCrossDayTime(currentTime);
      local timeSpan = nextCrossDayTime - currentTime;
      timeStr = CS.Torappu.FormatUtil.FormatTimeDelta(timeSpan);
    end
  end

  local remainTextFormat = StringRes.COMMON_LEFT_TIME;
  return luaUtils.Format(remainTextFormat, timeStr);
end




function ReturnSpecialOpenTypeModel:_GetTimeText(remainDay, openState)
  local timeStr = ""
  local daysTextFormat = StringRes.DAY_TEXT;
  if openState == ReturnSpecialOpenState.PAUSE then
    
    timeStr = luaUtils.Format(daysTextFormat, remainDay);
  else
    
    
    local timeDays = remainDay - 1;
    if timeDays > 0 then
      timeStr = luaUtils.Format(daysTextFormat, timeDays);
    else
      
      local currentTime = dateUtil.currentTime;
      local nextCrossDayTime = dateUtil.GetNextCrossDayTime(currentTime);
      local timeSpan = nextCrossDayTime - currentTime;
      timeStr = luaUtils.FormatTimeDelta(timeSpan);
    end
  end
  local remainTextFormat = StringRes.COMMON_LEFT_TIME;
  return luaUtils.Format(remainTextFormat, timeStr);
end





local ReturnSpecialOpenViewModel = Class("ReturnSpecialOpenViewModel");

function ReturnSpecialOpenViewModel:ctor()
  self.typeModels = {};
  self.isResOpenOnly = false;
  self.selectedType = ReturnAllOpenType.RESOURCE;
end

function ReturnSpecialOpenViewModel:LoadData()
  self.typeModels = {};
  self.isResOpenOnly = false;
  self.selectedType = ReturnAllOpenType.RESOURCE;

  local currentGroupData = ReturnModel.me:GetCurrentGroupData();
  if currentGroupData == nil then
    return;
  end
  local allOpenData = currentGroupData.allOpenData;
  if allOpenData == nil then
    return;
  end

  local isResOpenOnly = true;
  for i = 0, allOpenData.Count - 1 do
    local openData = allOpenData[i];
    if openData ~= nil then
      local model = ReturnSpecialOpenTypeModel.new();
      model:LoadData(openData);
      table.insert(self.typeModels, model);
      
      isResOpenOnly = isResOpenOnly and openData.allOpenType == ReturnAllOpenType.RESOURCE;
    end
  end
  self.isResOpenOnly = isResOpenOnly;
  table.sort(self.typeModels, function(a, b)
    return a.m_sortId < b.m_sortId
  end)
end


function ReturnSpecialOpenViewModel:RefreshPlayerData(playerData)
  local isSysFinish = ReturnModel.me:CheckIfOnlySpecialOpen(playerData);

  for i = #self.typeModels, 1, -1 do
    local model = self.typeModels[i];
    model:RefreshPlayerData(playerData);

    if isSysFinish and model.openState == ReturnSpecialOpenState.END then
      table.remove(self.typeModels, i);
    end
  end

  self.selectedType = self:_FindFirstSelection();
end

function ReturnSpecialOpenViewModel:GetSelectedOpenTypeModel()
  return self:_GetOpenTypeModel(self.selectedType);
end


function ReturnSpecialOpenViewModel:SetOpenType(openType)
  self.selectedType = openType;
end


function ReturnSpecialOpenViewModel:_GetOpenTypeModel(openType)
  for _, model in ipairs(self.typeModels) do
    if model.specialOpenType == openType then
      return model;
    end
  end
  return nil;
end


function ReturnSpecialOpenViewModel:_FindFirstSelection()
  local resourceModel = self:_GetOpenTypeModel(ReturnAllOpenType.RESOURCE);
  if resourceModel ~= nil and resourceModel.openState ~= ReturnSpecialOpenState.END then
    return ReturnAllOpenType.RESOURCE;
  end

  local campModel = self:_GetOpenTypeModel(ReturnAllOpenType.CAMP);
  if campModel ~= nil and campModel.openState ~= ReturnSpecialOpenState.END then
    return ReturnAllOpenType.CAMP;
  end

  LogError("[ReturnV2] No valid all open type.");
  return ReturnAllOpenType.RESOURCE;
end

return ReturnSpecialOpenViewModel;