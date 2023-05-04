

ModelMgr = Class("ModelMgr");
ModelMgr.s_definedModel = {};
ModelMgr.s_models = {};

function ModelMgr.Init()
  for _, cls in ipairs(ModelMgr.s_definedModel) do
    local model = cls.new();
    cls.me = model;
    table.insert(ModelMgr.s_models, model);
  end

  for _, model in ipairs(ModelMgr.s_models) do
    model:Init();
  end

  for _, model in ipairs(ModelMgr.s_models) do
    model:AfterInit();
  end
end

function ModelMgr.Dispose()
  for _, model in ipairs(ModelMgr.s_models) do
    model:Dispose();
    model.class.me = nil;
  end
  ModelMgr.s_models = {};
end 

function ModelMgr.DefineModel(name)
  local modelClass = Class(name, ModelBase);
  table.insert(ModelMgr.s_definedModel, modelClass);
  return modelClass; 
end