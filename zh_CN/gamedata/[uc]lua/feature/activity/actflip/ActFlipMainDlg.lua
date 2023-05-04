local luaUtils = CS.Torappu.Lua.Util;


































ActFlipMainDlg = Class("ActFlipMainDlg", DlgBase)

local ActFlipCardDlg = require("Feature/Activity/ActFlip/ActFlipCardDlg")
local ActFlipViewModel = require("Feature/Activity/ActFlip/ActFlipViewModel")
local ActFlipGrandDlg = require("Feature/Activity/ActFlip/ActFlipGrandDlg")


function ActFlipMainDlg:OnInit()
  local actId = self.m_parent:GetData("actId")
  self:_InitFromGameData(actId)
  self:_InitPanel()
  self.m_blockClick = false
  self.m_cardListAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._cardAdapter, 
      self._CreateCard, self._GetCardCount, self._UpdateCard);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClick)
  self:AddButtonClickListener(self._btnStart, self.EventOnStartClick)
  self:AddButtonClickListener(self._btnGrand, self.EventOnGrandClick)

  self.m_viewModel = ActFlipViewModel.new()
  self.m_viewModel:InitData(actId)
  self:_RefreshContent()
end

function ActFlipMainDlg:_InitPanel()
  self.m_grandItem = self:CreateWidgetByGO(ActFlipGrandDlg, self._objGrand)
end

function ActFlipMainDlg:_InitFromGameData(actId)
  self.m_actId = actId
  local dynActs = CS.Torappu.ActivityDB.data.dynActs;
  if actId == nil or dynActs == nil then
    return
  end
  local suc, jObject = dynActs:TryGetValue(actId)
  if not suc then
    luaUtils.LogError("Activity not found in dynActs : "..actId)
    return
  end
  local data = luaUtils.ConvertJObjectToLuaTable(jObject)
  self.m_grandRewards = data.grandRewards;
  self.m_grandPrizeDesc = data.grandPrizeDesc;
  self._textRule.text = data.ruleDesc;
  self.m_showPrizeIdList = data.showPrizeId;

  self._apSupplyTime.text = "";
  if data.apSupplyOutOfDateDict then
    for apid, endtime in pairs(data.apSupplyOutOfDateDict) do
      local apItemData = CS.Torappu.UI.UIItemViewModel();
      apItemData:LoadGameData(apid, CS.Torappu.ItemType.NONE);
      local dateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endtime);
      local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,dateTime.Year, dateTime.Month, dateTime.Day,dateTime.Hour,dateTime.Minute);
      local str = CS.Torappu.StringRes.ACT4D0_AP_REMAIN;
      self._apSupplyTime.text = CS.Torappu.Lua.Util.Format(str, apItemData.name, timedesc);
      break;
    end
  end

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_actId)
  if not suc then 
    return;
  end
  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime)
  self._textTime.text = CS.Torappu.Lua.Util.Format(
    CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
    endTime.Year, 
    endTime.Month, 
    endTime.Day, 
    endTime.Hour, 
    endTime.Minute
  );
end


function ActFlipMainDlg:_RefreshContent()
  local viewModel = self.m_viewModel
  if viewModel == nil then
    return
  end
  
  self:_RefreshBasicPacks()
  
  self:_RefreshTextsAndButtons()
  self.m_cardListAdapter:NotifyDataSetChanged();
end

function ActFlipMainDlg:_RefreshTextsAndButtons()
  local unGrand = self.m_viewModel.grandType ==  ActFlipViewModel.GrandState.UNGET
  
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelBtnSelect, 
      unGrand and not self.m_viewModel.hasPrayed and not self.m_viewModel.isSelected)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelBtnStart, 
      unGrand and not self.m_viewModel.hasPrayed and self.m_viewModel.isSelected)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelBtnFinishToday, 
      unGrand and self.m_viewModel.hasPrayed)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelBtnGrand, 
      self.m_viewModel.grandType == ActFlipViewModel.GrandState.GET)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelBtnFinishAll, 
      self.m_viewModel.grandType == ActFlipViewModel.GrandState.FINISH)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelTipNormal, 
      unGrand and not self.m_viewModel.hasPrayed and not self.m_viewModel.luckyToday)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelTipWait, 
      unGrand and self.m_viewModel.hasPrayed and not self.m_viewModel.isLastDay)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelTipLucky, 
      unGrand and not self.m_viewModel.hasPrayed and self.m_viewModel.luckyToday)
  
  self:_SetTip()
end

function ActFlipMainDlg:_RefreshBasicPacks()
  self.m_grandItem:Update(self.m_viewModel, self)

  local prizeId0 = self.m_showPrizeIdList[1];
  if (prizeId0) then
    local prizeId0AvailFlag = self.m_viewModel:isInclude(prizeId0, self.m_viewModel.receivedPrizeIds)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._canvasGroupMask1,prizeId0AvailFlag)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._objSpecialGet1,prizeId0AvailFlag)
  end

  local prizeId1 = self.m_showPrizeIdList[2];
  if (prizeId1) then
    local prizeId1AvailFlag = self.m_viewModel:isInclude(prizeId1, self.m_viewModel.receivedPrizeIds)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._canvasGroupMask2,prizeId1AvailFlag)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._objSpecialGet2,prizeId1AvailFlag)
  end

end


function ActFlipMainDlg:_SetTip()
  if self.m_viewModel.grandType == ActFlipViewModel.GrandState.UNGET then
    if self.m_viewModel.hasPrayed then
      local ct = CS.Torappu.DateTimeUtil.currentTime
      local crossTime = CS.Torappu.DateTimeUtil.GetNextCrossDayTime(ct)
      self._textWait.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_FLIPONLY_REFRESH_TIP, 
          CS.Torappu.FormatUtil.FormatTimeDelta(crossTime - ct))
    elseif not self.m_viewModel.luckyToday then
      self._textNormal.text = luaUtils.Format(CS.Torappu.StringRes.ACTIVITY_FLIPONLY_RAMAIN_TIP, 
          self.m_viewModel.remainingRaffleCount)
    end
  end
end


function ActFlipMainDlg:_CreateCard(gameObj)
  local card = self:CreateWidgetByGO(ActFlipCardDlg, gameObj)
  return card;
end

function ActFlipMainDlg:_GetCardCount()
  if self.m_viewModel == nil or self.m_viewModel.itemList == nil then
    return 0;
  end
  return #self.m_viewModel.itemList;
end

function ActFlipMainDlg:_UpdateCard(index, card)
  local idx = index + 1;
  card:Update(idx, self.m_viewModel.itemList[idx], self.m_viewModel.isSelected, self)
end


function ActFlipMainDlg:_EventOnCloseClick()
  if self.m_blockClick then
    return
  end
  self:Close();
end 

function ActFlipMainDlg:_EventOnCardSelect(idx, pos)
  
  if self.m_blockClick then
    return
  end

  local viewModel = self.m_viewModel
  if viewModel == nil then
    return
  end

  self.m_viewModel:_selectCard(idx, pos)
  self:_RefreshContent()
end 

function ActFlipMainDlg:EventOnStartClick()
  if self.m_blockClick then
    return
  end
  local pos = self.m_viewModel.selectPos
  self:_HandleRaffle(pos)
end

function ActFlipMainDlg:EventOnGrandClick()
  if self.m_blockClick then
    return
  end
  self:_HandleGetGrandReward()
end

function ActFlipMainDlg:_HandleRaffle(pos)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  
  self.m_blockClick = true;

  UISender.me:SendRequest(
    ActFlipServiceCode.RAFFLE,
    {
      activityId = self.m_actId,
      position = pos
    }, 
    {
      hideMask = true,
      onProceed = Event.Create(self, self._HandleRaffleResponse,pos)
    }
  );
end

function ActFlipMainDlg:_PlayLuckAnim(response)
  self._luckAnim:InitIfNot()
  self._luckAnim:SampleClipAtBegin("flip_lucky");
  CS.Torappu.TorappuAudio.PlayUI(
    CS.Torappu.Audio.Consts.InternalSounds[CS.Torappu.Audio.UiInternalSoundType.PopupMessagebox]);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelLucky, true)
  local option = {
    isFillAfter = true,
    isInverse = false,
    onAnimEnd = function()
      CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.rewards);
      CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelLucky, false);
      self.m_blockClick = false;
    end,
  }
  self._luckAnim:Play("flip_lucky",option);
end

function ActFlipMainDlg:_HandleRaffleResponse(response, pos)
  local extra = response.extraRaffle
  if extra ~= 0 then
    self.m_viewModel:InitData(self.m_actId)
    self:_RefreshContent()
    self:OnShowEffect(response, pos, true)
  else
    
    self.m_viewModel:InitData(self.m_actId)
    self:_RefreshContent()
    self:OnShowEffect(response, pos, false)
  end
end



function ActFlipMainDlg:OnShowEffect(response, pos, showLuckFlag)
  for i,v in ipairs(self.m_viewModel.itemList) do
    if (v.pos == pos) then      
      local item = self.m_cardListAdapter:FindViewByIndex(v.index - 1);
      if item then
        item:OnPlayEffect(function()
          if (showLuckFlag) then
            self:_PlayLuckAnim(response)
          else
            CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.rewards);
            self.m_blockClick = false;
          end
        end)
      end
    end
  end

end

function ActFlipMainDlg:_HandleGetGrandReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  
  UISender.me:SendRequest(
    ActFlipServiceCode.GET_REWARD,
    {
      activityId = self.m_actId,
    }, 
    {
      hideMask = true,
      onProceed = Event.Create(self, self._HandleGetGrandRewardResponse)
    }
  );
end

function ActFlipMainDlg:_HandleGetGrandRewardResponse(response)
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.rewards);
  self.m_viewModel:InitData(self.m_actId)
  self:_RefreshContent()
end


