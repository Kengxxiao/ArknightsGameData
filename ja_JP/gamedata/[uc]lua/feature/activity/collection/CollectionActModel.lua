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
  if actid == CollectionActID.act3d5 then
    return
    {
      baseColor = ColorRes.COMMON_BLUE,
      baseColorHex = "0075A9";
      pointItemName = CS.Torappu.I18N.StringMap.Get("ACTIVITY_3D5_POINT_SIMPLE_NAME");
      taskItemScale = 0.7;
    };
  elseif actid == CollectionActID.act4d5 then
    return
    {
      baseColor = CS.UnityEngine.Color(0.973,0.412,0.000);
      baseColorHex = "F86900";
      pointItemName = CS.Torappu.I18N.StringMap.Get("ACTIVITY_4D5_POINT_SIMPLE_NAME");
      taskItemScale = 0.5;
    };
  elseif actid == CollectionActID.act6d8 then
    return
    {
      baseColor = CS.UnityEngine.Color(1.000,0.255,0.157);
      baseColorHex = "ff4128";
      pointItemName = CS.Torappu.I18N.StringMap.Get("ACTIVITY_6D8_POINT_SIMPLE_NAME");
      taskItemScale = 0.5;
    };
  elseif actid == CollectionActID.act9d4 then
    return
    {
      baseColor = CS.UnityEngine.Color(0.957,0.396,0.145);
      baseColorHex = "f46525";
      pointItemName = CS.Torappu.I18N.StringMap.Get("ACTIVITY_9D4_POINT_SIMPLE_NAME");
      taskItemScale = 0.5;
    };
  end
end

ActivityServiceCode = 
{
  GET_COLLECTION_REWARD = "/activity/getActivityCollectionReward";
  CHECK_COLLECTION_MISSIONS = "/activity/confirmActivityMissionList";
}
ActivityServiceCode = Readonly(ActivityServiceCode);