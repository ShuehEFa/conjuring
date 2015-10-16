--[[
%% properties

%% globals

--]]

--[[
  @author eFa
  @date   104.10.12
  @brief  監看device property或global value的變化紀錄

  @note   將想要觀察的property寫在properties trigger, global value寫在globals trigger
          https://youtu.be/0O4zPEvPDiw
--]]

local triggerSource = fibaro:getSourceTrigger()
if triggerSource.type == "property" then
  local id = triggerSource.deviceID
  local name = triggerSource.propertyName
  local value = fibaro:getValue( id , name )
  print( "Device #" .. id .. " " .. name .. " = " .. value )
elseif triggerSource.type == "global" then
  local global = triggerSource.name
  local value = fibaro:getGlobalValue( global )
  print( "Global " .. global .. " = " .. value )
end