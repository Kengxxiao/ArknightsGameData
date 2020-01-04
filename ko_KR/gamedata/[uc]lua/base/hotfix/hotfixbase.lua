--[[
Base class for all hotfixers, a hotfixer contains a group of fine-grained hotfixes.
]]

---@class HotfixBase
---@field private m_fixes {class:string|object, method:stirng}[]
HotfixBase = Class("HotfixBase")

HotfixBase.m_fixes = nil;

---@protected 使用此接口做修复操作，无需要手动释放，会自动处理
function HotfixBase:Fix(cls, method_name, fixFunc)
  xlua.hotfix(cls, method_name, fixFunc);
  self:_Record(cls, method_name);
end

function HotfixBase:Fix_ex(cls, method_name, fixFunc)
  local util = require 'xlua.util'
  util.hotfix_ex(cls, method_name, fixFunc);
  self:_Record(cls, method_name);
end

function HotfixBase:_Record(cls, method_name)
  if self.m_fixes == nil then
    self.m_fixes = {};
  end
  self.m_fixes[#self.m_fixes + 1] = {class = cls, method = method_name}; 
end

function HotfixBase:Init()
  self:OnInit();
end

function HotfixBase:Dispose()
  self:OnDispose();
  if self.m_fixes then
    for _, fix in ipairs(self.m_fixes) do
      xlua.hotfix(fix.class, fix.method, nil);
    end
    self.m_fixes = nil;
  end
end

---@protected to override by child class
function HotfixBase:OnInit()
  
end


---@protected to override by child class
function HotfixBase:OnDispose()
  
end