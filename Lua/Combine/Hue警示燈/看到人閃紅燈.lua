--[[
%% properties
382 value
%% globals
--]]

tSourceDevice = fibaro:getSourceTrigger()

tDevice = { 382 }

function LightRed()
  i = 1
  while 1 do 
    if ( (i % 2) == 1) then
	  fibaro:call( 369 , "pressButton", "3")      
    else
      fibaro:call( 369 , "pressButton", "4")        	
	end
	fibaro:sleep( 1000 )
	i = i + 1
	
	scene47 = fibaro:countScenes( 47 )
--	print(scene47)
	if ( scene47 > 0 ) then
	  fibaro:call( 369 , "pressButton", "4")
	  fibaro:abort()
	end    	
  end
  fibaro:call( 369 , "pressButton", "4")
  --fibaro:abort()
end
		
for i = 1 , #tDevice do		
  if ( (tonumber(fibaro:getValue( tDevice[i] , "value")) > 0) and (tonumber(fibaro:getValue( tDevice[i] , "armed")) > 0 )) then
    print("保全有開，這是張眼動作")
    fibaro:debug(json.encode(tSourceDevice))
    LightRed()        
  elseif ( (tonumber(fibaro:getValue( tDevice[i] , "value")) == 0) and (tonumber(fibaro:getValue( tDevice[i] , "armed")) > 0 )) then
    print("保全有開，這是閉眼動作")
  elseif(tonumber(fibaro:getValue( tDevice[i] , "armed")) == 0) then 
    fibaro:debug(json.encode(tSourceDevice))
    print("保全沒開，不理會")
  end
end
