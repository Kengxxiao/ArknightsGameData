
local LuaUIUtil = CS.Torappu.Lua.LuaUIUtil;






DlgBase = Class("DlgBase", UIBase);
DlgBase.s_ids = 1;


function DlgBase:OnInitialize()
  self.m_id = DlgBase.s_ids;
  DlgBase.s_ids = DlgBase.s_ids + 1;
  local closeBtn = self.m_layout.sysCloseButton;
  if closeBtn then
    self:AddButtonClickListener(closeBtn, self._HandleSysClose);
  end
  self.m_widgets = UIWidgetContainer.new(self)

  self:OnInit();
end


function DlgBase:OnDispose()
  self.m_widgets:Clear();
  self:OnClose();

  DlgMgr.ClearDlg(self);
end

function DlgBase:Close()
  self.m_parent:RequestClose(self);
end

function DlgBase:_HandleSysClose()
  self:Close();
end

function DlgBase:IsClosed()
  return self:IsDestroy();
end

function DlgBase:Id()
  return self.m_id;
end







function DlgBase:CreateWidgetByPrefab(widgetCls, layout, parent)
  return self.m_widgets:CreateWidgetByPrefab(widgetCls, layout, parent);
end






function DlgBase:CreateWidgetByGO(widgetCls, layout)
  return self.m_widgets:CreateWidgetByGO(widgetCls, layout);
end



function DlgBase:OnInit()
end

function DlgBase:OnClose()
end





function DlgBase:ClosedByParent()
  self:Dispose();
end


function DlgBase:GetGroup()
  return self.m_parent:GetGroup();
end


function DlgBase:GetHookRoot()
  return self.m_parent:GetHookRoot();
end



function DlgBase:GetData(key)
  return self.m_parent:GetData(key);
end


function DlgBase:GetParamData()
  return self.m_parent.paramData;
end


function DlgBase:RequestClose(child)
  local group = self:GetGroup();
  if group then
    group:RemoveChild(child);
  else
    CS.Torappu.Lua.Util.LogError("Can't find group:"..self.__cname );
  end
end



function DlgBase:LoadPrefab(path)
  return self.m_parent:LoadPrefab(path);
end



function DlgBase:LoadLayout( path)
  return self.m_parent:LoadLayout(path);
end



function DlgBase:LoadSprite(path)
  return self.m_parent:LoadSprite(path);
end




function DlgBase:LoadSpriteFromAutoPackHub(hubPath, spriteName)
  return self.m_parent:LoadSpriteFromAutoPackHub(hubPath, spriteName);
end

function DlgBase:GetLuaLayout()
  return self.m_layout
end

function DlgBase:ShowEnterEffect()
end

function DlgBase:IsEnterEffectEnd()
  return true
end


function DlgBase:CreateViewModel(viewModelCls)
  if not viewModelCls then
    LogError("dataCls can't be nil");
    return nil;
  end
  if not IsSubclassOf(viewModelCls, UIViewModel) then
    LogError(viewModelCls.__cname .. " must be the subclass of UIViewModel")
    return nil
  end
  return viewModelCls.new(self);
end


function DlgBase:_UpdateViewModel(viewModel)
  if self.m_updateViewTimer then
    return;
  end
  self.m_updateViewTimer = self:NextFrame(self._DoUpdateViewModel, viewModel);
end

function DlgBase:_DoUpdateViewModel(viewModel)
  self.m_updateViewTimer = nil;
  self.m_widgets:EnumerateAllWidgets(function(widget)
    widget:OnViewModelUpdate(viewModel);
  end);
end