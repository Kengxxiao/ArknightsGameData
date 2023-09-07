UIPushMsgPath = 
{
  ACT4FUN_CAMERA_UP = "act4funCameraLvUpdate";
  ACT4FUN_FIRST_GOOD_END = "act4funGoodEndingForTheFirstTime";
  ACT4FUN_PASS_TRAIN = "act4funPassTrainingStage";
}
Readonly(UIPushMsgPath);



UIPushMessageHandler = ModelMgr.DefineModel("UIPushMessageHandler");
UIPushMessageHandler.s_msgHandlers = nil;

UIPushMessageHandler.s_funcMap = nil;

function UIPushMessageHandler:OnInit()
  CS.Torappu.UI.UIPushMessageHandler.GetLuaHandlersToRegister = UIPushMessageHandler._BuildMsgHandlerList;
end

function UIPushMessageHandler:OnDispose()
  CS.Torappu.UI.UIPushMessageHandler.GetLuaHandlersToRegister = nil;
  if UIPushMessageHandler.s_msgHandlers then
    for _, handler in ipairs(UIPushMessageHandler.s_msgHandlers) do
      CS.Torappu.UI.UIPushMessageHandler.UnRegisterLuaHandler(handler.msgPath);
      handler:Clear();
    end
    UIPushMessageHandler.s_msgHandlers = nil;
  end
end

function UIPushMessageHandler._BuildMsgHandlerList()
  if not UIPushMessageHandler.s_msgHandlers then
    UIPushMessageHandler.s_msgHandlers = {};
    local funcMap = UIPushMessageHandler.s_funcMap;
    if funcMap then
      for path, func in pairs(funcMap) do
        local handler = CS.Torappu.UI.UIPushMessageHandler.MsgLuaHandler(path, func);
        table.insert(UIPushMessageHandler.s_msgHandlers, handler);
      end
    end
  end
  return UIPushMessageHandler.s_msgHandlers;
end



function UIPushMessageHandler.RegisterHandleFunc(path, func)
  if not UIPushMessageHandler.s_funcMap then
    UIPushMessageHandler.s_funcMap = {};
  end
  if UIPushMessageHandler.s_funcMap[path] then
    LogError("Already register function for " .. path);
  end
  UIPushMessageHandler.s_funcMap[path] = func;
end