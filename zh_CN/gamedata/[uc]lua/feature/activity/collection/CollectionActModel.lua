CollectionActID = 
{
  act3d5 = "act3d5",
  act4d5 = "act4d5",
  act6d8 = "act6d8",
  act9d4 = "act9d4",
}
CollectionActID = Readonly(CollectionActID);




CollectionActModel =  ModelMgr.DefineModel("CollectionActModel");


local ColorRes = CS.Torappu.ColorRes;


function CollectionActModel:FindBasicInfo(actId)
  
  local suc, ret = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  return ret;
end


function CollectionActModel:FindPointRewardItem(actId)
  local itemView = nil;
  
  local suc, itemsInCfg = CS.Torappu.ActivityDB.data.activity.defaultCollectionData:TryGetValue(actId);
  if suc then
    local itemId = nil;
    if itemsInCfg.collections.Count > 0 then
      itemId = itemsInCfg.collections[0].pointId;
    end

    itemView = CS.Torappu.UI.UIItemViewModel();
    itemView:LoadGameData(itemId, CS.Torappu.ItemType.NONE);
  else
    CS.Torappu.Lua.Util.LogError( CS.Torappu.Lua.Util.Format("can't find {0} collection cfg from activity data", actId));
  end
  return itemView;
end




function CollectionActModel:GetMissionGroup(actId)
  for idx, cur in pairs(CS.Torappu.ActivityDB.data.missionGroup) do
    if cur.id == actId then
      return cur;
    end
  end
  return nil;
end

 
 
function CollectionActModel:FindMission(missionId )
  local missionList = CS.Torappu.ActivityDB.data.missionData;
  for idx, cur in pairs(missionList) do
    if cur.id == missionId then
      return cur;
    end
  end
  return nil;
end









function CollectionActModel:GetActCfg(actid)
  local cfg = {
    baseColor = CS.UnityEngine.Color.white;
    baseColorHex = "000000";
    pointItemName = "";
    taskItemScale = 0.5;
  }

  local suc, homeActCfg = CS.Torappu.ActivityDB.data.homeActConfig:TryGetValue(actid);
  if not suc then
    return cfg;
  end

  local pointItemViewModel = CollectionActModel.me:FindPointRewardItem(actid);

  cfg.pointItemName = pointItemViewModel.name;
  cfg.baseColorHex = homeActCfg.actTopBarColor;
  cfg.baseColor = CS.Torappu.ColorRes.TweenHtmlStringToColor(homeActCfg.actTopBarColor);
  return cfg;
end

ActivityServiceCode = 
{
  GET_COLLECTION_REWARD = "/activity/getActivityCollectionReward";
  CHECK_COLLECTION_MISSIONS = "/activity/confirmActivityMissionList";
}
ActivityServiceCode = Readonly(ActivityServiceCode);