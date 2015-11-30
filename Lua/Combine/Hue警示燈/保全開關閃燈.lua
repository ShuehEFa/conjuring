--[[
%% properties
382 armed
%% globals
--]]

--[[
  @author Lala
  @date   104.11.26
  @brief  保全開關閃燈
  @note   填寫trigger properties
--]]

tSourceDevice = fibaro:getSourceTrigger()

if ( tonumber(fibaro:getValue( tSourceDevice.deviceID , "armed")) > 0 ) then
  fibaro:call( 369 , "pressButton", "1")
  fibaro:sleep( 2500 )
  fibaro:call( 369 , "pressButton", "4")
elseif ( tonumber(fibaro:getValue( tSourceDevice.deviceID , "armed")) == 0 ) then
  fibaro:call( 369 , "pressButton", "2")
  fibaro:sleep( 500 )
  fibaro:call( 369 , "pressButton", "2")
  fibaro:sleep( 500 )
  fibaro:call( 369 , "pressButton", "2")
  fibaro:sleep( 2500 )
  fibaro:call( 369 , "pressButton", "4")		
end
