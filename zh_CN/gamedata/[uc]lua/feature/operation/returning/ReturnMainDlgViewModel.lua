










ReturnMainDlgViewModel = Class("ReturnMainDlgViewModel", UIViewModel);

local ReturnMissionViewModel = require("Feature/Operation/Returning/Mission/ReturnMissionViewModel");
local ReturnCheckinViewModel = require("Feature/Operation/Returning/Checkin/ReturnCheckinViewModel");
local ReturnSpecialOpenViewModel = require("Feature/Operation/Returning/SpecialOpen/ReturnSpecialOpenViewModel");
local ReturnPackageViewModel = require("Feature/Operation/Returning/Package/ReturnPackageViewModel");
local ReturnNewsViewModel = require("Feature/Operation/Returning/News/ReturnNewsViewModel");

function ReturnMainDlgViewModel:LoadData()
  self.missionViewModel = ReturnMissionViewModel.new();
  self.missionViewModel:LoadData();

  self.checkinViewModel = ReturnCheckinViewModel.new();
  self.checkinViewModel:LoadData();

  self.specialOpenViewModel = ReturnSpecialOpenViewModel.new();
  self.specialOpenViewModel:LoadData();

  self.packageViewModel = ReturnPackageViewModel.new();
  self.packageViewModel:LoadData();

  self.newsViewModel = ReturnNewsViewModel.new();
  self.newsViewModel:LoadData();

  self.showNoticeBtn = self:_CheckIfShowNoticeBtn();

  self:RefreshPlayerData();
  self:_SetUpTabState();
end

function ReturnMainDlgViewModel:_SetUpTabState()
  if(self.sysClose) then
    self.tabState = ReturnTabState.STATE_TAB_NEWS;
  else
    self.tabState = ReturnTabState.STATE_TAB_CHECKIN;
  end
end

function ReturnMainDlgViewModel:RefreshPlayerData()
  local playerData = CS.Torappu.PlayerData.instance.data.backflow;

  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  self.checkinViewModel:RefreshItemStatus();
  self.missionViewModel:RefreshPlayerData(playerData);
  self.specialOpenViewModel:RefreshPlayerData(playerData);
  self.packageViewModel:RefreshPlayerData(playerData);
  
  self.sysClose = ReturnModel.me:CheckIfOnlySpecialOpen(playerData);
  self.hasSpecialOpen = ReturnModel.me:CheckIfFullOpen(playerData);
end

function ReturnMainDlgViewModel:_CheckIfShowNoticeBtn()
  local playerData = CS.Torappu.PlayerData.instance.data.backflow;
  if playerData == nil then
    return false;
  end
  local playerGroupId = playerData.currentV2.groupId;
  local returnData = CS.Torappu.OpenServerDB.returnData;
  if returnData == nil or returnData.constData == nil then
    return false;
  end
  return playerGroupId == returnData.constData.oldReturnGroupId;
end

function ReturnMainDlgViewModel:SetCheckinTabStatus()
  self.tabState = ReturnTabState.STATE_TAB_CHECKIN;
end

function ReturnMainDlgViewModel:SetMissionTabStatus()
  local missionModel = self.missionViewModel;
  if missionModel ~= nil and missionModel.seqNum ~= nil then
    missionModel.seqNum = missionModel.seqNum + 1;
  end
  self.tabState = ReturnTabState.STATE_TAB_MISSION;
end

function ReturnMainDlgViewModel:SetNewsTabStatus()
  self.tabState = ReturnTabState.STATE_TAB_NEWS;
end

function ReturnMainDlgViewModel:SetSpecialOpenTabStatus()
  self.tabState = ReturnTabState.STATE_TAB_SPECIAL_OPEN;
end

function ReturnMainDlgViewModel:SetPackageTabStatus()
  self.tabState = ReturnTabState.STATE_TAB_PACKAGE;
end

function ReturnMainDlgViewModel:GetGPTabShow()
  local tabShow = self.packageViewModel:CheckGroupGiftPackageAbleBuy();
  return not self.sysClose and tabShow;
end