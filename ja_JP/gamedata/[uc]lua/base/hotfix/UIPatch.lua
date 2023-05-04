






function ApplyUIHotPatch(root, path, comType, property, value)
  local trans = root.transform;
  if path ~= nil and path ~= "" then
    trans = root.transform:Find(path);
  end
  if not trans then
    LogError(string.format("Can't find target node:%s", path));
    return false;
  end
  local target = nil;
  if comType == "UnityEngine.GameObject" then
    target = trans.gameObject;
  elseif comType == "UnityEngine.RectTransform" or comType == "UnityEngine.Transform" then
    target = trans;
  else
    target = trans:GetComponent(comType);
  end
  if not target then
    LogError(string.format("Can't find targetObject %s", comType));
    return false;
  end
  local setter = UIHotPatchSetters[property];
  if setter then
    setter(target, value);
    return true;
  end
  return false;
end

UIHotPatchSetters = { }

UIHotPatchSetters["m_Text"] = function(target, value)
  target.text = value;
end

UIHotPatchSetters["m_IsActive"] = function(target, value)
  target:SetActive(value ~= "0");
end

UIHotPatchSetters["m_AnchoredPosition.x"] = function(target, value)
  local cur = target.anchoredPosition;
  cur.x = tonumber(value);
  target.anchoredPosition = cur;
end

UIHotPatchSetters["m_AnchoredPosition.y"] = function(target, value)
  local cur = target.anchoredPosition;
  cur.y = tonumber(value);
  target.anchoredPosition = cur;
end

UIHotPatchSetters["m_Color.r"] = function(target, value)
  local cur = target.color;
  cur.r = tonumber(value);
  target.color = cur;
end

UIHotPatchSetters["m_Color.g"] = function(target, value)
  local cur = target.color;
  cur.g = tonumber(value);
  target.color = cur;
end

UIHotPatchSetters["m_Color.b"] = function(target, value)
  local cur = target.color;
  cur.b = tonumber(value);
  target.color = cur;
end

UIHotPatchSetters["m_Color.a"] = function(target, value)
  local cur = target.color;
  cur.a = tonumber(value);
  target.color = cur;
end