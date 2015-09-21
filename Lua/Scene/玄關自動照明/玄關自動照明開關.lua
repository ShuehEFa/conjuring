--[[
%% autostart
%% properties

%% globals
--]]

--[[
  @author eFa
--]]

--##
local SCENE_ID = 19--455
--##

function Update()
  local date = os.date( '*t' )
  local time = string.format( '%02d%02d', date.hour , date.min )
  fibaro:debug( "Update @ " .. time )
  if date.wday > 1 and date.wday < 7 then
    if date.hour == 14 and date.min == 38 then
      fibaro:setSceneEnabled( SCENE_ID , false )
      fibaro:debug( '<span style="color:red">auto turn off</span>' )
    elseif date.hour == 14 and date.min == 39 then
      fibaro:setSceneEnabled( SCENE_ID , true )
      fibaro:startScene( SCENE_ID )
      fibaro:debug( '<span style="color:green">auto turn on</span>' )
    end
  end
  setTimeout( Update , 60000 )
end

local trigger = fibaro:getSourceTrigger()
fibaro:debug( '<span style="color:red">Trigger : ' .. trigger.type .. ". Scene Count : " .. fibaro:countScenes() .. "</span>" )
if trigger.type == "other" then
  if fibaro:isSceneEnabled( SCENE_ID ) then
    fibaro:setSceneEnabled( SCENE_ID , false )
    fibaro:debug( '<span style="color:red">manully turn off</span>' )
  else
    fibaro:setSceneEnabled( SCENE_ID , true )
    fibaro:startScene( SCENE_ID )
    fibaro:debug( '<span style="color:green">manully turn on</span>' )
  end
  if fibaro:countScenes() == 1 then
    Update()
  end
elseif trigger.type == "autostart" then
  Update()
end


