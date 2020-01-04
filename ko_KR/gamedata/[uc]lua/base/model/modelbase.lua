---@class ModelBase
ModelBase = Class("ModelBase");

---called by ModelMgr only
function ModelBase:Init()
  self:OnInit();
end

---called by ModelMgr only
function ModelBase:AfterInit()
end

---called by ModelMgr only
function ModelBase:Dispose()
  self:OnDispose();
end

--- called when init model
function ModelBase:OnInit()
end

--- called after all models has initialized
function ModelBase:OnAfterInit()
end

--- called when dispose model
function ModelBase:OnDispose()
end