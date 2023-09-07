


BridgeDlgBase = Class("BridgeDlgBase", DlgBase);


function BridgeDlgBase:OnInitialize()
  self.m_childDlgs = UIDlgGroup.new(self);
  BridgeDlgBase.super.OnInitialize(self);
end


function BridgeDlgBase:OnDispose()
  self.m_childDlgs:Clear();
  BridgeDlgBase.super.OnDispose(self);
end

function BridgeDlgBase:GetGroup()
  return self.m_childDlgs;
end

function BridgeDlgBase:IsPureGroup()
  return self.m_pureGroup;
end


function BridgeDlgBase:SetPureGroup()
  self.m_pureGroup = true;
end


function BridgeDlgBase:OnResume()
  local topDlg = self.m_childDlgs:GetTopDlg()
  if topDlg == nil then
    return
  end
  topDlg:OnResume()
end