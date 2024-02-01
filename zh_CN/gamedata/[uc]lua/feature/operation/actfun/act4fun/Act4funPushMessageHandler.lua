local luaUtils = CS.Torappu.Lua.Util;

Act4funPushMessageHandler = Class("Act4funPushMessageHandler");


function Act4funPushMessageHandler.HandleCameraUp(msgList)
  local constData = Act4funPushMessageHandler._GetConstData();
  if not constData then
    return;
  end
  for idx = 1, msgList.Count do
    luaUtils.TextToast(constData.tokenLevelUpToastTxt);
  end
end

function Act4funPushMessageHandler.HandleFirstGoodEnd(msgList)
  local constData = Act4funPushMessageHandler._GetConstData();
  if not constData then
    return;
  end
  for idx = 1, msgList.Count do
    luaUtils.TextToast(constData.goodEndingToastTxt);
  end
end

function Act4funPushMessageHandler.HandlePassTrain(msgList)
  local constData = Act4funPushMessageHandler._GetConstData();
  if not constData then
    return;
  end
  for idx = 1, msgList.Count do
    luaUtils.TextToast(constData.formalLevelUnlockToastTxt);
  end
end

function Act4funPushMessageHandler._GetConstData()
  return CS.Torappu.ActivityDB.data.actFunData.act4FunData.constant;

end

UIPushMessageHandler.RegisterHandleFunc(UIPushMsgPath.ACT4FUN_CAMERA_UP, Act4funPushMessageHandler.HandleCameraUp);
UIPushMessageHandler.RegisterHandleFunc(UIPushMsgPath.ACT4FUN_FIRST_GOOD_END, Act4funPushMessageHandler.HandleFirstGoodEnd);
UIPushMessageHandler.RegisterHandleFunc(UIPushMsgPath.ACT4FUN_PASS_TRAIN, Act4funPushMessageHandler.HandlePassTrain);
