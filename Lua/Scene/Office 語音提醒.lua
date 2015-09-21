--[[
%% autostart
%% properties
%% globals
--]]

--[[
  @author eFa
--]]

-- 日期行事曆 時間格式 MMDDhhmm
local mtDateNotice =
{
  [ '08280930' ] = 'wu~ wu~ ghost coming.' ,
  [ '08271600' ] = 'E, Fa, dont forget call your friend.' ,
}

-- 星期行事曆 時間格式 dhhmm
local mtWeekNotice = 
{
  [ '31600' ] = '現在是腦力激盪時間 請大家移往會議室吧.' ,
  [ '61700' ] = 'Everybody stand up. It is time of C O I, go go go.',
}

-- 工作天行事曆 時間格式 hhmm
local mtWorNnotices = 
{
  [ '0930' ] = 'Good Morning everyone, have a nice day.' ,
  [ '1000' ] = '有人要訂難吃的內科便當嗎.' ,
  [ '1030' ] = '內科中心訂便當時間已過.' ,
  [ '1100' ] = '請確認有訂到便當.' ,
  [ '1130' ] = '請即早外出搶購中午便當.' ,
  [ '1200' ] = 'Now 12 o clock.' ,
  [ '1530' ] = 'Time to tack a short break, QK QK.' ,
  [ '1800' ] = 'It is time to go home, everybody, thank you for hard working.' ,
  
  [ '1755' ] = '泰龍.請早點回家.陪老婆歐.歐' ,
}

local mtLetsTalkInEnglish =
{
  "You have to make a reservation at least a day in advane." ,
  "The liquor is strong. I can only take a sip!" ,
  "Put some hot sauce on the side, please." ,
  "How do you like your steak, rear, medium, or well done?" ,
  "The meat is very tender." ,
  "Don't finish it. Save some for me." ,
  "He's a big eater." ,
  "When do strawberries come into season?" ,
  "Can I have a bite." ,
  "This contact was signed under the director's name." ,
  "Scotch on the rock." ,
  "May I have the check please?" ,
  "Don't eat too much junk food." ,
  "I'm not drunk, i'm very sober." ,
  "Don't talk with your mouth full." ,
  "You barely touch your food." ,
  "I propose a toast." ,
  "Which do you prefer, scrambled eggs or boiled eggs?" ,
  "I can't drink soda becaues it gives me gas." ,
  "Chew it well. I don't want you to choke." ,
  "The coffee is too strong." ,
  "These kids are fussy about taste." ,
  "I'm full. I'm stuffed." ,
  "Can you deliver it?" ,
  "I lost my appetite." ,
  "How do you want your coffee?" ,
  "I like my coffee black." ,
  "Drink more milk. It will do you good." ,
  "She's a vegetarian." ,
  "I smell something buring." ,
  "Drinking some wine won't do you any harm." ,
  "Can we spilt that piece of cake?" ,
  "Do you know how democracy got its start?" ,
  "He saw a number of students bullying one of their classmates." ,
  "Commemorating the beginning of a new era." ,
  "This camera is now on sale for 19 dollars only." ,
  "She splashed out $1500 on a camera." ,
  "The standard of living in Taiwan has topped the world." ,
}

function Say( _text )
  local prefix = "lng=en|dr=auto|vol=30|txt="
  local textLen = _text:len()
  for i = 1 , textLen do
    if string.byte( _text:sub( i ) ) > 127 then
      prefix = prefix:gsub( "lng=en|" , "lng=zh|" )
      break
    end
  end
  fibaro:setGlobal( 'OfficeSonosTTS' , prefix .. _text .. '|' )
  fibaro:debug( '<span style="color:yellow">' .. prefix .. _text .. '</span>' )
end

function CheckContain( _tTable , _key )
  for key , value in pairs( _tTable ) do
    if key == _key then
      Say( value )
      return true
    end
  end
  return false
end

function Update()
  local date = os.date( '*t' )
  local time = string.format( '%02d%02d', date.hour , date.min )
  local weekTime = tostring( date.wday ) .. time
  local dateTime = string.format( '%02d%02d', date.month , date.day ) .. time
--  fibaro:debug( 'Update @ ' .. time .. ' / ' .. weekTime .. ' / ' .. dateTime )
  
  if CheckContain( mtDateNotice , dateTime ) then 

  elseif CheckContain( mtWeekNotice , weekTime ) then
    
  elseif date.wday > 1 and date.wday < 7 then
    if CheckContain( mtWorNnotices , time ) then
      
    elseif time == "1035" then
      Say( "Let's talk in english." )
      fibaro:sleep( 5000 )
      math.randomseed( os.time() )
      Say( mtLetsTalkInEnglish[ math.random( #mtLetsTalkInEnglish ) ] )
    end 
  end
  setTimeout( Update , 60000 )
end

if fibaro:getSourceTriggerType() == "autostart" then
  fibaro:debug( "start" )
  Update()
end

