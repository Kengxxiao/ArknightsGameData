local eutil = CS.Torappu.Lua.Util















local MainlineBuffMissionGroupView = Class("MainlineBuffMissionGroupView", UIPanel);

local MainlineBuffMissionView = require("Feature/Activity/MainlineBuff/MainlineBuffMissionView");


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true;
  end
  return false;
end





function MainlineBuffMissionGroupView:Init(host, loadSpriteFunc, onMissionItemClick, onZoneClick)
  self.m_host = host;
  self.m_loadSpriteFunc = loadSpriteFunc;
  self.m_onMissionItemClick = onMissionItemClick;
  self.m_onZoneClick = onZoneClick;
end


function MainlineBuffMissionGroupView:Render(viewModel)
  self:_InitIfNot();
  
  local viewCache = self.m_viewCache;
  if _CheckIfValueDirty(viewCache.bannerImgName, viewModel.bannerImgName) then
    local hubPath = CS.Torappu.ResourceUrls.GetMainlineBuffHubPath(viewModel.actId);
    self._imgTitle.sprite = self.m_loadSpriteFunc(self.m_host, hubPath, viewModel.bannerImgName);
    viewCache.bannerImgName = viewModel.bannerImgName;
  end
  if _CheckIfValueDirty(viewCache.apSupplyEndTimeDesc, viewModel.apSupplyEndTimeDesc) then
    self._textApSupplyEndTime.text = viewModel.apSupplyEndTimeDesc;
    viewCache.apSupplyEndTimeDesc = viewModel.apSupplyEndTimeDesc;
  end

  self.m_viewModel = viewModel;
  self.m_missionAdapter:NotifyDataSetChanged();
end

function MainlineBuffMissionGroupView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  self.m_viewCache = {};
  self.m_missionAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._missionLayout,
      self._CreateMissionView, self._GetMissionCount, self._UpdateMissionView);

  self:AddButtonClickListener(self._btnFocusOnZone, self._OnFocusZoneClick);
end

function MainlineBuffMissionGroupView:_GetMissionCount()
  if self.m_viewModel == nil or self.m_viewModel.missionModelList == nil then
    return 0;
  end
  return #self.m_viewModel.missionModelList;
end


function MainlineBuffMissionGroupView:_CreateMissionView(gameObj)
  local view = self:CreateWidgetByGO(MainlineBuffMissionView, gameObj);
  view:Init(self, self._OnMissionItemClick);
  return view;
end



function MainlineBuffMissionGroupView:_UpdateMissionView(index, view)
  view:Render(self.m_viewModel.missionModelList[index + 1]);
end



function MainlineBuffMissionGroupView:_OnMissionItemClick(missionGroupId ,missionId)
  if self.m_host == nil or self.m_onMissionItemClick == nil or 
      missionGroupId == nil or missionGroupId == "" or missionId == nil or missionId == "" then
    return;
  end
  self.m_onMissionItemClick(self.m_host, missionGroupId, missionId);
end

function MainlineBuffMissionGroupView:_OnFocusZoneClick()
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  local zoneId = viewModel.zoneId;
  if self.m_host == nil or self.m_onZoneClick == nil or zoneId == nil or zoneId == "" then
    return;
  end
  self.m_onZoneClick(self.m_host, zoneId);
end

return MainlineBuffMissionGroupView;