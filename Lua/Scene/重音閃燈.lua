--[[
%% properties
%% globals
--]]

--[[
  @author Lala
  @date   104.12.07
  @brief  配合音樂重音亮燈
  @note   填寫seismometerID、lightID
--]]

local seismometerID = 499 --震動感測器
local lightID = 506  --要量的燈

local lastTemper = 0
local tamper = tonumber( fibaro:getValue( seismometerID, "value" ) )
print(tamper)

if fibaro:countScenes() > 1 then
  fibaro:abort()
end

while 1 do
  tamper = tonumber( fibaro:getValue( seismometerID, "value" ) )
  if tamper ~= lastTemper then 
    print(tamper)		
    if ((tamper > 0) and (tamper < 255)) then
      fibaro:call(lightID , "turnOn")
    else
      fibaro:call(lightID , "turnOff")	  
    end  
  end
  lastTemper = tamper
  fibaro:sleep(10)
end