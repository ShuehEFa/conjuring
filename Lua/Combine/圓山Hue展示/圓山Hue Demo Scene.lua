--[[
%% autostart
%% properties
%% globals
--]]

--[[
  @author eFa
--]]

if fibaro:getSourceTriggerType() == 'autostart' then
local mSleepMSec = 1000
local gLightProgram = "LightProgram"
local gHueId = "HueId"
local gHueCommand = "HueCommand"
local mHueCtrlDeviceId = 992
local mHueCtrlSentButtonId = 9

local lightProgramString = ""
local tHue = {}
local tRgbw = {}
local nowTime = 0
local startTime = 0

function DoHueCommand( _id , _text )
  tTable = {}
  local i , j , value = 1 , 1 , ""
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value == "1" then
    tTable.on = true
  elseif value == "0" then
    tTable.on = false
  end
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value ~= "-" then
    tTable.bri = tonumber( value )
  end
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value ~= "-" then
    tTable.hue = math.floor( tonumber( value ) * 65535 / 254 )
  end
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value ~= "-" then
    tTable.sat = tonumber( value )
  end
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value == "0" then
    tTable.alert = "none"
  elseif value == "1" then
    tTable.alert = "select"
  elseif value == "2" then
    tTable.alert = "lselect"
  end
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value == "0" then
    tTable.effect = "none"
  elseif value == "1" then
    tTable.effect = "colorloop"
  end
  
  fibaro:setGlobal( gHueId , _id )
  local command = json.encode( tTable )
  fibaro:setGlobal( gHueCommand , command ) 
  fibaro:call( mHueCtrlDeviceId , "pressButton" , mHueCtrlSentButtonId )
    
--  local socket = Net.FHttp( mHueIp , mHuePort )
--  socket:PUT('/api/' .. mHueUser ..'/lights/' .. _id .. '/state' , json.encode( tTable ) )
end

function DoRgbwCommand( _id , _text )
  tTable = {}
  local i , j , value = 1 , 1 , ""
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value == "0" then
    fibaro:call( _id , "turnOff" )
    return
  end
  
  j = _text:find( "," , i )
  value = _text:sub( i , j - 1 )
  i = j + 1
  if value ~= "0" then
    fibaro:call( _id , "startProgram" , tonumber( value ) )
    return
  end
  
  j = _text:find( "," , i )
  local r = _text:sub( i , j - 1 )
  i = j + 1
  j = _text:find( "," , i )
  local g = _text:sub( i , j - 1 )
  i = j + 1
  j = _text:find( "," , i )
  local b = _text:sub( i , j - 1 )
  i = j + 1
  j = _text:find( "," , i )
  local w = _text:sub( i , j - 1 )
  i = j + 1
  fibaro:call( _id , "setColor" , r , g , b , w )
end

function UpdateLight( _tTable , _isHue )
  local count = 0
  for i = 1 , #_tTable do
    local maxFrame = #( _tTable[ i ].timeline )
    local change = false
    if _tTable[ i ].frameIdx < maxFrame then
      if _tTable[ i ].timeline[ _tTable[ i ].frameIdx + 1 ].time <= nowTime then
        _tTable[ i ].frameIdx = _tTable[ i ].frameIdx + 1 
        change = true
      end
    elseif _tTable[ i ].loop then
      _tTable[ i ].frameIdx = 1
      change = true
      for j = 1 , maxFrame do
        _tTable[ i ].timeline[ j ].time = _tTable[ i ].timeline[ j ].time + _tTable[ i ].timeline[ maxFrame ].time
      end
    end
    if change then
	  if _isHue then
        for j = 1 , #( _tTable[ i ].id ) do
--          fibaro:debug( "HUE" .. j )
          DoHueCommand( _tTable[ i ].id[ j ] , _tTable[ i ].timeline[ _tTable[ i ].frameIdx ].value )
--          fibaro:debug( "HUE" .. j )
          count = count + 1
            fibaro:sleep( 300 )
          --if count % 5 == 0 then fibaro:debug( "SLEEP" ) fibaro:sleep( 1000 ) end
        end
      else
        for j = 1 , #( _tTable[ i ].id ) do
--          fibaro:debug( "RGBW" .. j )
          DoRgbwCommand( _tTable[ i ].id[ j ] , _tTable[ i ].timeline[ _tTable[ i ].frameIdx ].value )
--          fibaro:debug( "RGBW" .. j )
        end
      end
    end
  end
end

while true do
  lightProgramString = fibaro:getGlobal( gLightProgram )
  fibaro:setGlobal( gLightProgram , "" )  
  if lightProgramString ~= "" then
    local tLightProgram = json.decode( lightProgramString )
      fibaro:debug( "Light: " .. type( tLightProgram ) )
      fibaro:debug( "Hue: " .. type( tLightProgram.hue ) )
    tHue = tLightProgram.hue
      fibaro:debug( "RGBW: " .. type( tLightProgram.rgbw ) )
    tRgbw = tLightProgram.rgbw
    startTime = os.time()
  end
  
  nowTime = os.time() - startTime
  
  UpdateLight( tHue , true )
  UpdateLight( tRgbw , false )

  fibaro:sleep( mSleepMSec )
end

fibaro:debug( "END?" )
  
end