
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
  
  if self.m_childDlgs then
    for _, child in ipairs(self.m_childDlgs) do
      child:ClosedByParent();
    end
    self.m_childDlgs = nil;
  end
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


function DlgBase:CreateChildDlg(dlgCls)
  local child = DlgMgr.CreateDlg(dlgCls, self);
  if not self.m_childDlgs then
    self.m_childDlgs = {};
  end
  table.insert(self.m_childDlgs, child);
  return child;
end

function DlgBase:GetChildDlg(dlgCls)
  if not self.m_childDlgs then
    return nil;
  end
  for _, child in ipairs(self.m_childDlgs) do
    if child.class == dlgCls then
      return child;
    end
  end
  return nil;
end

function DlgBase:FetchChildDlg(dlgCls)
  local child = self:GetChildDlg(dlgCls);
  if not child then
    child = self:CreateChildDlg(dlgCls);
  end
  return child;
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


function DlgBase:GetHookRoot()
  return self.m_parent:GetHookRoot();
end



function DlgBase:GetData(key)
  return self.m_parent:GetData(key);
end


function DlgBase:RequestClose(child)
  if self.m_childDlgs ~= nil then
    for idx, achild in ipairs(self.m_childDlgs) do
      if achild == child then
        table.remove(self.m_childDlgs, idx);
        child:ClosedByParent();
        return;
      end
    end
  end
  CS.Torappu.Lua.Util.LogError(string.format("[%s]not the child of this dialog[%s]", child, self) );
end



function DlgBase:LoadPrefab(path)
  return self.m_parent:LoadPrefab(path);
end



function DlgBase:LoadLayout( path)
  return self.m_parent:LoadLayout(path);
end

function UIBase:GetLuaLayout()
  return self.m_layout
end