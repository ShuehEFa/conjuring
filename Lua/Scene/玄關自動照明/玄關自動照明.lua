--[[
%% properties
81 value
303 value
%% globals
--]]

--[[
  @author eFa
--]]

local DoorId = 81
local LightId = 303
local MaintainSec = 20
local SelfId = 19
local IsShowLog = false

function debugLog( _str )
  if IsShowLog then
    fibaro:debug( _str )
  end
end
  
local Trigger = fibaro:getSourceTrigger()
if( Trigger[ 'type' ] == 'property' ) then
 
  local ActiveID = fibaro:countScenes()
  local IsAlreadyWork = fibaro:countScenes() > 1
  local IsDoorTriger = ( Trigger[ 'deviceID' ] == DoorId )
  local DoorState = fibaro:get( DoorId , 'value' )
  local LightState = fibaro:get( LightId , 'value' )
  
  debugLog( '#' .. ActiveID .. ', Already Work: ' .. tostring( IsAlreadyWork ) .. ', Trigger by Door: ' .. tostring( IsDoorTriger ) .. ', Door State: ' .. DoorState .. ', Lisght State: ' .. LightState )
  
  if IsAlreadyWork then
    if IsDoorTriger then
      if DoorState == '1' then
        debugLog( '#' .. ActiveID .. ' 開門延長時間　　　　　　　　　　' )
        fibaro:sleep( MaintainSec * 1000 )
        if fibaro:countScenes() == 1 then
          debugLog( '#' .. ActiveID .. ' 開門延長時間正常終止　　　　　　　　　　' )
          fibaro:call( LightId , 'turnOff' )   
        else
          debugLog( '#' .. ActiveID .. ' 開門延長時間遭終止　　　　　　　　　　' )
        end
      else
        debugLog( '#' .. ActiveID .. ' 關門不理會　　　　　　　　　　' )
      end
    else
      if LightState == '0' then
        debugLog( '#' .. ActiveID .. ' 關燈直接停止情境 　　　　　　　　　　' )
        fibaro:killScenes( SelfId )
      else
        debugLog( '#' .. ActiveID .. ' 可能是自動開燈也可能是同時開門開燈　　　　　　　　　　' )
      end
    end
  elseif IsDoorTriger and DoorState == '1' and LightState == '0' then 
    debugLog( '#' .. ActiveID .. ' 自動開燈' )
    fibaro:call( LightId , 'turnOn' )
    fibaro:sleep( MaintainSec * 1000 )
    if fibaro:countScenes() == 1 then
      debugLog( '#' .. ActiveID .. ' 正常情況自動關燈　　　　　　　　　　' )
      fibaro:call( LightId , 'turnOff' ) 
    else
      debugLog( '#' .. ActiveID .. ' 正常情況自動關燈遭終止　　　　　　　　　　' )
    end
  else
    debugLog( '#' .. ActiveID .. ' 條件未滿　　　　　　　　　　' )
  end
end

