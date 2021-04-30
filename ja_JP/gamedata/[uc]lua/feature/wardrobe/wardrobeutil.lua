WardrobeUtil = Class("WardrobeUtil");

function WardrobeUtil.CheckSkinListOnSale(skinList)
  local currentTime =CS.Torappu.DateTimeUtil.timeStampNow
  for k,v in pairs(skinList) do
    if WardrobeUtil.CheckSkinOnSale(v)  then
      return true
    end
  end
  return false
end

function WardrobeUtil.CheckSkinOnSale(v)
  local currentTime = CS.Torappu.DateTimeUtil.timeStampNow
  if (not v.onSale ) then
    return false
  end
  if (v.shopData.startDateTime < 0 and v.shopData.endDateTime<0) then
    return CS.Torappu.CharacterUtil.CheckUnlimitSkinBuyInLimitTime(v.data.skinId)
  end


  return (currentTime >= v.shopData.startDateTime or v.shopData.startDateTime  < 0)and (currentTime <= v.shopData.endDateTime or v.shopData.endDateTime  < 0)
end

WardrobeUtil.GET_SKIN_UNLOCK_FLAG = "GET_SKIN_UNLOCK_FLAG"

function WardrobeUtil.GetSkinUnGetFlag()
  if (WardrobeUtil.showUnGetFlag == nil) then
    WardrobeUtil.showUnGetFlag = CS.Torappu.PlayerPrefsWrapper.GetUserInt(WardrobeUtil.GET_SKIN_UNLOCK_FLAG, 0) == 0;
  end
  return WardrobeUtil.showUnGetFlag
end

function WardrobeUtil.SetSkinUnGetFlag(value)
  local flag = 0;
  if (value) then
    flag = 0
  else
    flag = 1
  end
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(WardrobeUtil.GET_SKIN_UNLOCK_FLAG, flag);
  WardrobeUtil.showUnGetFlag = value
end