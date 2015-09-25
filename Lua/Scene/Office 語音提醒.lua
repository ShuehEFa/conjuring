--[[
%% autostart
%% properties
%% globals
--]]

--[[
  @author eFa
  @date   104.09.25
  @brief  於特定時間播放Sonos語音

  @note   當語音的時間點相同時，語音執行優先權：
		  	1. mtDateNotice > mtWeekNotice > mtWorNnotices > mtLetsTalkInEnglish
		  	2. 在同一個Table下，越前面越先被搜尋到的先說
			3. 語音一個時間點只會說一句，所以越晚被執行會覆蓋先前的語音
--]]

local gTTS = "SonosTTS"	-- Sonos TTS的global value
local mVol = 40			-- 語音音量

-- 日期行事曆 時間格式 MMDDhhmm(月日時分)
local mtDateNotice =
{
  [ '12080930' ] = 'Happy birthday to you, FLH, Wu Ho' ,
}

-- 星期行事曆 時間格式 dhhmm(星期時分)，星期日是1，星期一是2，星期六是7
local mtWeekNotice = 
{
  [ '31600' ] = '現在是腦力激盪時間 請大家移往會議室吧.' ,
  [ '61700' ] = 'Everybody stand up. It is time of C O I, go go go.',
}

-- 工作天行事曆 時間格式 hhmm(時分)，僅週一到週五會播放
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

local mUseLetsTalkInEnglish = true		-- 是否使用每日說英語功能
local mLetsTalkInEnglishTime = "0945"	-- 每日說英語播放時間，格式同mtWorNnotices
-- 每日一句，會隨機播放其中一句
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

--[[
  @brief 告訴Sonos要說什麼話
  @_text 字串，要Sonos說的話，可以中文或英文，但不能中文標點符號，僅能英文以下符號" ,.!?'"
  @_time 數字，語音播放時間，不填寫使用預設auto
--]]
function Say( _text , _time )
  if _time == nil then _time = "auto" end
  local prefix = "lng=en|dr=" .. tostring( _time ) .. "|vol=" .. mVol .. "|txt="
  local textLen = _text:len()
  for i = 1 , textLen do
    if string.byte( _text:sub( i ) ) > 127 then
      prefix = prefix:gsub( "lng=en|" , "lng=zh|" )
      break
    end
  end
  fibaro:setGlobal( gTTS , prefix .. _text .. '|' )
  print( os.date() )
  print( '<span style="color:yellow">' .. prefix .. _text .. '</span>' )
end

--[[
  @brief   檢查指定Table是否含有指定Key的值
  @_tTable Table，被查詢的Table
  @_key	   字串，查找的Key
  @return  Bool，是否找到
--]]
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
  -- 優先播放mtDateNotice
  if CheckContain( mtDateNotice , dateTime ) then 
  -- 其次播放mtWeekNotice
  elseif CheckContain( mtWeekNotice , weekTime ) then
  -- 再來判斷是否工作日  
  elseif date.wday > 1 and date.wday < 7 then
    -- 檢查mtWorNnotices
    if CheckContain( mtWorNnotices , time ) then
    -- 最後判斷是否啟動說英文模式及時間點是否符合  
    elseif time == mLetsTalkInEnglishTime and mUseLetsTalkInEnglish then
      Say( "Let's talk in english." )
      fibaro:sleep( 10000 )
      math.randomseed( os.time() )
      Say( mtLetsTalkInEnglish[ math.random( #mtLetsTalkInEnglish ) ] )
    end 
  end
  setTimeout( Update , 60000 )
end

-- main
if fibaro:getSourceTriggerType() == "autostart" then
  print( "start @ " .. os.date() )
  Update()
end

