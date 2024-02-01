local eutil = CS.Torappu.Lua.Util;




















local BlessOnlyBlessListHorizontalItem = Class("BlessOnlyBlessListHorizontalItem", UIPanel);


function BlessOnlyBlessListHorizontalItem:OnInit()
  local avatarPrefab = CS.Torappu.UI.PlayerAvatarUtil.GetAvatarViewPrefab();
  if avatarPrefab ~= nil then 
    self.m_avatarView = CS.UnityEngine.GameObject.Instantiate(avatarPrefab, self._avatarContainer):GetComponent("PlayerAvatarView");
  end
end



function BlessOnlyBlessListHorizontalItem:Render(data, illustLoader)
  if data == nil or data.openPacketModel == nil or data.openPacketModel.curBlessItemModel == nil then 
    return;
  end

  local curBlessItemModel = data.openPacketModel.curBlessItemModel;
  self._charNameText.text = curBlessItemModel.charName;
  local blessingGroupRenderData = self._blessingAtlasObject:GetSpriteByName(data.openPacketModel.blessingGroup);
  self._blessingGroupImg:SetSprite(blessingGroupRenderData);

  local avatarSprite = eutil.GetPlayerAvatarSprite(data.avatarInfo);
  self.m_avatarView:Render(avatarSprite);

  if self._crossAppShareAvatarContent ~= nil then
    local avatarModel = CS.Torappu.UI.CrossAppShare.CrossAppShareAvatarModel();
    avatarModel:InitModel(true, avatarSprite);
    self._crossAppShareAvatarContent.dynAssetModel = avatarModel;
  end

  local blessingText = data.openPacketModel.curBlessItemModel.charBlessing;
  self._charBlessingText.text = blessingText;
  self._charBlessingShadow.text = blessingText;
  self._playerIdText.text = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_UID_FORMAT, data.playerId);
  self._playerNameText.text = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_NAME_FORMAT, data.playerName, data.playerNameId);
  self._playerLvText.text = tostring(data.playerLevel);
  
  if self.m_cachedBlessItemModel ~= curBlessItemModel and illustLoader ~= nil then
    self.m_cachedBlessItemModel = curBlessItemModel;

    local skin = CS.Torappu.CharUISkinStruct(curBlessItemModel.charId, curBlessItemModel.charSkinId);
    local scale = tonumber(self._illustScale);
    if self._crossAppShareIllustContent ~= nil then
      local illustModel = CS.Torappu.UI.CrossAppShare.CrossAppShareIllustModel();
      illustModel:InitModel(true, skin, scale);
      self._crossAppShareIllustContent.dynAssetModel = illustModel;
    end
   
    eutil.ClearAllChildren(self._illustContainer);
    local illust = eutil.LoadStaticChrIllust(illustLoader, skin, self._illustContainer);

    if illust ~= nil then 
      illust.rectTransform.sizeDelta = illust.rectTransform.sizeDelta * scale;
    end
  end
end


function BlessOnlyBlessListHorizontalItem:CreateRemakeCollector()
  local param = CS.Torappu.Activity.Act1Blessing.Act1BlessingHorizontalItemModelCollector.CollectParam();
  
  param.charNameText = self._charNameText;
  param.blessingGroupImg = self._blessingGroupImg;
  param.charBlessingText = self._charBlessingText;
  param.charBlessingShadow = self._charBlessingShadow;
  param.playerIdText = self._playerIdText;
  param.playerNameText = self._playerNameText;
  param.playerLvText = self._playerLvText;
  param.avatarContent = self._crossAppShareAvatarContent;
  param.illustContent = self._crossAppShareIllustContent;

  local collector = CS.Torappu.Activity.Act1Blessing.Act1BlessingHorizontalItemModelCollector();
  collector:InitCollector(param);
  collector:CollectModel();
  return collector;
end

return BlessOnlyBlessListHorizontalItem;