
ModelBase = Class("ModelBase");


function ModelBase:Init()
  self:OnInit();
end


function ModelBase:AfterInit()
end


function ModelBase:Dispose()
  self:OnDispose();
end


function ModelBase:OnInit()
end


function ModelBase:OnAfterInit()
end


function ModelBase:OnDispose()
end