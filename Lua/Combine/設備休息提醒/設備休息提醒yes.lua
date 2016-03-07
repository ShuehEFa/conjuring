--[[
%% properties

%% globals
--]]

--[[ 
  @author Lala
  @date   105.3.2
  @brief  僅供用於配合"設備休息提醒"Scene
  @note   填寫device之Id、類型、若為VD可填寫該VD之"關閉"按鈕號碼 
          實體設備範例 tDevice = {id = 723, type = "physical"}
          VD範例 tDevice = {id = 501, type = "virtual", button = 3}
]]--

local tDevice = {id = 723, type = "physical"}
--local tDevice = {id = 501, type = "virtual", button = 3}   

local gVirtualSwitch = "restWarning"

if (tDevice.type == "physical") then
  fibaro:call(tDevice.id, "turnOff")
elseif (tDevice.type == "virtual") then
  fibaro:setGlobal(gVirtualSwitch, "off")
  fibaro:call(tDevice.id, "pressButton", tDevice.button)
end



