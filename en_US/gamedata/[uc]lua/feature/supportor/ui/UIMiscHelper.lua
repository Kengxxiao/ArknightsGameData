UIMiscHelper = Class("UIMiscHelper")



function UIMiscHelper.ShowGainedItems(items)
  local List_RewardItemModel = CS.System.Collections.Generic.List(CS.Torappu.Activity.RewardItemModel)
  local countList = List_RewardItemModel()
  for idx = 1, #items do
    local rewardItemModel = CS.Torappu.Activity.RewardItemModel()
    local resItem = items[idx]
    rewardItemModel.type = resItem.type
    rewardItemModel.id = resItem.id
    rewardItemModel.count = resItem.count
    if resItem.charGet ~= nil then
      local gachaResult = CS.Torappu.GachaResult()
      gachaResult.charInstId = resItem.charGet.charInstId
      gachaResult.charId = resItem.charGet.charId
      gachaResult.isNew = resItem.charGet.isNew == 1
      if #resItem.charGet.itemGet > 0 then
        local itemArray = CS.System.Array.CreateInstance(typeof(CS.Torappu.ItemBundle), #resItem.charGet.itemGet)
        for i = 1, #resItem.charGet.itemGet do
          local itemGet = resItem.charGet.itemGet[i]
          local typeEnum = CS.Torappu.ItemType.__CastFrom(itemGet.type)
          local itemBundle = CS.Torappu.ItemBundle(itemGet.id, typeEnum, itemGet.count)
          itemArray[i - 1] = itemBundle
        end
        gachaResult.itemGet = itemArray
      end
      if resItem.charGet.potent ~= nil then
        local potential = CS.Torappu.GachaResult.PotentialInfo()
        potential.delta = resItem.charGet.potent.delta
        potential.now = resItem.charGet.potent.now
        gachaResult.potent = potential
      end
      rewardItemModel.charGet = gachaResult
    end
    countList:Add(rewardItemModel)
  end
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(countList)
end