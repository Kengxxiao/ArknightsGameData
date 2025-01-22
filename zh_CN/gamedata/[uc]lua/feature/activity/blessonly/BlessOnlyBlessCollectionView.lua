local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween
local luaUtils = CS.Torappu.Lua.Util;




















local BlessOnlyBlessCollectionView = Class("BlessOnlyBlessCollectionView", UIPanel);

function BlessOnlyBlessCollectionView:OnInit()
  self:AddButtonClickListener(self._closeBtn, self._OnClickCloseBtn);
  self:AddButtonClickListener(self._fullScreenBtn, self._OnClickCloseBtn);
  self:AddButtonClickListener(self._shareBtn, self._OnClickShareBtn);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._closeBtn);

  self.m_switchTween = FadeSwitchTween(self._canvasGroup)
  self.m_switchTween:Reset(false)
  
  local avatarPrefab = CS.Torappu.UI.PlayerAvatarUtil.GetAvatarViewPrefab();
  if avatarPrefab ~= nil then 
    self.m_avatarView = CS.UnityEngine.GameObject.Instantiate(avatarPrefab, self._avatarContainer):GetComponent("PlayerAvatarView");
  end
end


function BlessOnlyBlessCollectionView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  self.m_actId = data:GetActId();
  self.m_switchTween.isShow = data.panelState == BlessOnlyPanelState.BLESS_COLLECTION;
  if data.panelState ~= BlessOnlyPanelState.BLESS_COLLECTION then
    return;
  end

  self.m_avatarView:Render(data.avatarInfo);
  
  if self._crossAppShareAvatarContent ~= nil then
    local avatarModel = CS.Torappu.UI.CrossAppShare.CrossAppShareAvatarModel();
    avatarModel:InitModel(true, data.avatarInfo);
    self._crossAppShareAvatarContent.dynAssetModel = avatarModel;
  end

  self._playerIdText.text = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_UID_FORMAT, data.playerId);
  self._playerNameText.text = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_NAME_FORMAT, data.playerName, data.playerNameId);
  self._playerLvText.text = tostring(data.playerLevel);

  SetGameObjectActive(self._shareBtn.gameObject, CS.Torappu.UI.CrossAppShare.CrossAppShareUtil.CheckBtnInTimeByMissionId(data.shareMissionId, false));
  self.m_cachedShareMissionId = data.shareMissionId;

  self:_RenderFesAvatars(data);
end


function BlessOnlyBlessCollectionView:_RenderFesAvatars(data)
  local hubPath = CS.Torappu.ResourceUrls.GetCharAvatarHubPath();
  local fesModel1 = data:GetPacketByOrder(1);
  if fesModel1 ~= nil then
    self._charAvatar1.sprite = self:LoadSpriteFromAutoPackHub(hubPath, fesModel1.defaultFesCharAvatarId);
  end
  local fesModel2 = data:GetPacketByOrder(2);
  if fesModel2 ~= nil then
    self._charAvatar2.sprite = self:LoadSpriteFromAutoPackHub(hubPath, fesModel2.defaultFesCharAvatarId);
  end
  local fesModel3 = data:GetPacketByOrder(3);
  if fesModel3 ~= nil then
    self._charAvatar3.sprite = self:LoadSpriteFromAutoPackHub(hubPath, fesModel3.defaultFesCharAvatarId);
  end
  local fesModel4 = data:GetPacketByOrder(4);
  if fesModel4 ~= nil then
    self._charAvatar4.sprite = self:LoadSpriteFromAutoPackHub(hubPath, fesModel4.defaultFesCharAvatarId);
  end
end

function BlessOnlyBlessCollectionView:_OnClickCloseBtn()
  if self.onClickCloseBtn == nil then
    return
  end
  Event.Call(self.onClickCloseBtn);
end

function BlessOnlyBlessCollectionView:_CreateBlessCollectionCollector()
  local param = CS.Torappu.UI.Act1Blessing.Act1BlessingBlessCollectionModelCollector.CollectParam();
  param.charAvatar1 = self._charAvatar1;
  param.charAvatar2 = self._charAvatar2;
  param.charAvatar3 = self._charAvatar3;
  param.charAvatar4 = self._charAvatar4;
  param.playerIdText = self._playerIdText;
  param.playerNameText = self._playerNameText;
  param.playerLvText = self._playerLvText;
  param.avatarContent = self._crossAppShareAvatarContent;

  local collector = CS.Torappu.UI.Act1Blessing.Act1BlessingBlessCollectionModelCollector();
  collector:InitCollector(param);
  collector:CollectModel();
  return collector;
end

function BlessOnlyBlessCollectionView:_OnClickShareBtn()
  if self.m_switchTween ~= nil and self.m_switchTween.isTweening then
    return;
  end
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if CS.Torappu.UI.UIPageController.isTransiting then
    return;
  end
  local prefabPath = CS.Torappu.ResourceUrls.GetActBlessOnlyRemakeBlessCollectionPath(self.m_actId);
  local collector = self:_CreateBlessCollectionCollector();
  local remakeController = self:LoadPrefab(prefabPath):GetComponent("Torappu.UI.CrossAppShare.CrossAppShareRemakeController");

  local option = CS.Torappu.UI.UIPageOption();
  local inputParam = CS.Torappu.UI.CrossAppShare.CrossAppSharePage.InputParam();
  inputParam.remakePrefab = remakeController;
  inputParam.additionModel = nil;
  inputParam.modelCollector = collector;
  inputParam.shareMissionId = self.m_cachedShareMissionId;
  inputParam.effectType = CS.Torappu.UI.CrossAppShare.CrossAppShareDisplayEffects.EffectType.CAMERA_SIZE_TWEEN;
  option.args = inputParam;

  self:OpenPage3(CS.Torappu.UI.UIPageNames.CROSS_APP_SHARE_PAGE, option);
end

return BlessOnlyBlessCollectionView