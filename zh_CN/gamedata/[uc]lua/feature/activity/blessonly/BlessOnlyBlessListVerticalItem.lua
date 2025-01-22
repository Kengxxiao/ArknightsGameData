local eutil = CS.Torappu.Lua.Util;












local BlessOnlyBlessListVerticalItem = Class("BlessOnlyBlessListVerticalItem", UIPanel);



function BlessOnlyBlessListVerticalItem:Render(data, illustLoader)
  if data == nil or data.openPacketModel == nil or data.openPacketModel.curBlessItemModel == nil then 
    return;
  end
  local curBlessItemModel = data.openPacketModel.curBlessItemModel;
  self._charNameText.text = curBlessItemModel.charName;
  local blessingGroupRenderData = self._blessingAtlasObject:GetSpriteByName(data.openPacketModel.blessingGroup);
  self._blessingGroupImg:SetSprite(blessingGroupRenderData);

  self._charNameShadow.text = data.openPacketModel.curBlessItemModel.charName;

  if self.m_cachedBlessItemModel ~= curBlessItemModel and illustLoader ~= nil then
    self.m_cachedBlessItemModel = curBlessItemModel;

    local skin = CS.Torappu.CharUISkinStruct(curBlessItemModel.charId, curBlessItemModel.charSkinId);

    if self._crossAppShareIllustContent ~= nil then
      local illustModel = CS.Torappu.UI.CrossAppShare.CrossAppShareIllustModel();
      illustModel:InitModel(true, skin);
      self._crossAppShareIllustContent.dynAssetModel = illustModel;
    end
   
    eutil.ClearAllChildren(self._illustContainer);
    local illust = eutil.LoadStaticChrIllust(illustLoader, skin, self._illustContainer);
  end
end


function BlessOnlyBlessListVerticalItem:CreateRemakeCollector()
  local param = CS.Torappu.Activity.Act1Blessing.Act1BlessingVerticalItemModelCollector.CollectParam();
  
  param.charNameText = self._charNameText;
  param.blessingGroupImg = self._blessingGroupImg;
  param.charNameShadow = self._charNameShadow;
  param.illustContent = self._crossAppShareIllustContent;
  
  local collector = CS.Torappu.Activity.Act1Blessing.Act1BlessingVerticalItemModelCollector();
  collector:InitCollector(param);
  collector:CollectModel();
  return collector;
end


function BlessOnlyBlessListVerticalItem:CheckIsShareIllustModelNil()
  return self._crossAppShareIllustContent.dynAssetModel == nil;
end

return BlessOnlyBlessListVerticalItem;