




local luaUtil = CS.Torappu.Lua.Util;
local OpenServerV3MissionTaskPartView = Class("OpenServerV3MissionTaskPartView", UIWidget);


function OpenServerV3MissionTaskPartView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  if self._textType ~= nil then
    self._textType.text = viewModel.tagTypeDesc;
  end
  if self._textDesc ~= nil then
    self._textDesc.text = viewModel.desc;
  end
  if self._textProgress ~= nil then
    self._textProgress.text = string.format("%s/%s",
        luaUtil.FormatNumberWithUnit(viewModel.value),
        luaUtil.FormatNumberWithUnit(viewModel.target));
  end
  if self._sliderProgress ~= nil then
    self._sliderProgress.value = viewModel.progress;
  end
end

return OpenServerV3MissionTaskPartView;
