--[[
%% properties
671 value
%% globals
smartLight2
--]]

--[[
  @author Lala
  @date   105.02.17
  @brief  根據時段調整燈光
  @note   
    - 本情境僅供VD配合使用，請勿顯示於使用者介面上
    - 填寫實體開關Id、Virtual device Id
--]]



local switchId = 671   --實體開關Id
local VDId = 684       --Virtual Device

--__--__--__--__--
local VDUpdate = 24    --update button
local checkTime = 23   
local gLightValue = "smartLight"
local gTime = "smartLight2"

local trigger = fibaro:getSourceTrigger()
local switch = fibaro:getValue(switchId, "value")

local deviceValue = fibaro:getGlobal(gLightValue)
local tDeviceValue = json.decode(deviceValue)
local selectTime = fibaro:getGlobal(gTime)

if (fibaro:countScenes() > 1) then
--  fibaro:abort()
end

--trigger為properties時，若 switch = 0 則關燈，若 switch = 1 則按update

if (trigger.type == "property") then
  if ( switch == "0" ) then
    print("關閉")
	fibaro:call(VDId, "setProperty", "ui.Label1.value", "未選擇")
    fibaro:call(VDId, "setProperty", "ui.Label2.value", "未選擇")
	for i = 1, #tDeviceValue do
	  fibaro:call(tDeviceValue[i].id, "turnOff")
	end
  else
    print("開啟")
	fibaro:call(VDId, "pressButton", checkTime)
	fibaro:sleep(500)
	fibaro:call(VDId, "pressButton", VDUpdate)	
  end
  
--trigger為globals時，若 switch = 0, 不做事，若 switch = 1 則按update
elseif ((trigger.type == "global") or (trigger.type == "other")) then
  print("global")
  if (switch == "0") then
    print("關閉中，不做事")
  else
    print("自動調整燈光")
    fibaro:sleep(2000)
	fibaro:call(VDId, "pressButton", VDUpdate)
  end
end
