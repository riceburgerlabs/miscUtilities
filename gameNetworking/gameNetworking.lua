local public = {}

-- table of already completed achievements
-- will check if achievement has already been completed before network call
local achievementList = table.load( "achievements.json" ) or {} 

-- set up environment for either android or game center
local gpgs, gameCenter, sortAchievements
local platform
if onAndroid then
	platform = "GPGS"
	gpgs = require( "plugin.gpgs" )
	gpgs.userInitiated = false
elseif oniOS then
	platform = "gameCenter"
	gameCenter = require( "gameNetwork" )
else 
	platform = "GPGS" -- for testing purposes onlu-- gameCenter or GPGS
end

-- stores the achievementList to a json file for future use
local store = function( )
	table.save( achievementList, "achievements.json" )
end 

local sortedAchievements = {}

-- require data from gameNetworkingData

public.loadData = function(path)
	local gameNetworkingData = require (path)
	public.leaderBoards = gameNetworkingData.leaderBoards or {}
	public.achievements = gameNetworkingData.achievements or {}
	sortAchievements()
end

-- return the plaform,  good for loading images etc
public.returnPlatform = function()
	return platform
end


-- Accesses top leaderboard scores
public.loadScores = function(params)
	local leaderboard = params and params.leaderboard
	leaderboard = leaderboard and public.leaderBoards[leaderboard][platform] or nil
	if leaderboard == nil then return end

	-- Set up optional value (and defaults) so correct for each platform
	-- Both
	local friendsOnly = platform == "GPGS" and (params.friendsOnly or false) or (platform == "gameCenter" and (params.friendsOnly and "FriendsOnly" or "Global"))
	local timeSpan = platform == "GPGS" and (params.timeSpan or "all time") or (platform == "gameCenter" and (params.timeSpan == "weekly" and "Week" or params.timeSpan == "daily" and "Today" or "AllTime"))
	local callback = params.callback or function() end
	
	-- Game Center
	local rangeLow = params.rangeLow or 1 
	local rangeHigh = params.rangeHigh or 5

	-- GPGS
	local reload = params.reload or true
	local position = params.position or "top"
	local limit  = params.limit or 25

	if ( gpgs ) then
		local function listener (event)
			if event and event.scores then
				callback(event)
			end
		end
		gpgs.leaderboards.loadScores({leaderboardId = leaderboard, limit = limit, reload = reload, position = position, timeSpan = timeSpan, limit = 1, friendsOnly = friendsOnly, listener = listener} )
	elseif ( gameCenter ) then
		local function requestCallback( event )		   	
	   		callback(event)		   	
		end
		gameCenter.request( "loadScores",
	    {
	        leaderboard =
	        {
	            category = leaderboard,
	            playerScope = friendsOnly,  -- "Global" or "FriendsOnly"
	            timeScope = timeSpan,   -- "AllTime", "Week", or "Today"
	            range = { rangeLow,rangeHigh }
	        },
	        listener = requestCallback
		    }
		)
	end
end

local function gpgsLoginListener( event )
   if event and event.isError then
   		-- if there has been a failed loggin and the user initiated the loggin then load the fail call back function
   		-- else fail silently
   		if gpgs.userInitiated == true then
   			public.failLogInCallback(event.errorMessage)
   		end
   else
   		if event.name == "login" and event.phase == "logged in" then
			public.successLoginCallback()
   		elseif event.name == "login" and event.phase == "logged out" then
   			-- user correctly logged out
   			public.loggedOutCallback()
   		end

   end
end

-- Android function
local function gpgsInitListener( event )
 
    if not event.isError then
        if ( event.name == "init" ) then  -- Initialization event
            -- Attempt to log in the user
            print("gpgsInitListener init")
            gpgs.login( { userInitiated=gpgs.userInitiated, listener=gpgsLoginListener } )
 
        elseif ( event.name == "login" ) then  -- Successful login event
        	print("Successfully logged into GPGS")
            table.print_r(event)
        end
    end
end


 
-- Apple Game Center functions

local function gcInitListener( event )
 	table.print_r(event)
    if event.data then  -- Successful login event
    	print("Successfully logged into GameCenter")
    	public.successLoginCallback()
    end
end


-- Public/Access Functions to log into Game Network
public.login = function(params)

	-- store any callbacks
	public.failLogInCallback = params and params.failLogInCallback or function() end
	public.successLoginCallback = params and params.successLoginCallback or function() end
	public.loggedOutCallback = params and params.loggedOutCallback or function() end
	if onSimulator then 
		return 
	end
	if ( gpgs ) then
		 -- Initialize Google Play Games Services
		gpgs.userInitiated = params and params.userInitiated or false
	    gpgs.init( gpgsInitListener )
	elseif ( gameCenter ) then
	    -- Initialize Apple Game Center
	    gameCenter.init( "gamecenter", gcInitListener )
	end
end

public.isConnected = function ()
	if onSimulator then return end
	return onAndroid and gpgs.isConnected()
end

-- submit a new high score to the appropriate leaderboard
public.submitScore = function (score, leaderboard)
	if not score then return end -- if no score is supplied then exit

	if not leaderboard then -- if no leaderboard is given then return the first leaderboard on the sorted leaderboard list
		for i, v in pairs(public.leaderBoards) do
			leaderboard = i
			break
		end
	end
	local leaderboard = public.leaderBoards[leaderboard][platform] or nil

	print("Submitting score ", score, " to leaderboard ", leaderboard)

	local function submitScoreListener( event )
 
	end


	if ( gpgs ) then
        -- Submit a score to Google Play Games Services
        gpgs.leaderboards.submit(
        {
            leaderboardId = leaderboard,
            score = score,
            listener = submitScoreListener
        })
 
    elseif ( gameCenter ) then
        -- Submit a score to Apple Game Center
        gameCenter.request( "setHighScore",
        {
            localPlayerScore = {
                category = leaderboard,
                value = score
            },
            listener = submitScoreListener
        })
    end
end


-- submit a new achievement to the appropriate game network
public.submitAchievement = function(achievementID, params)

	local achievementID = achievementID and public.achievements[achievementID][platform] or nil
	if not achievementID then
		return
	end

	-- check if achievenment has alread been done, if so then return
	if achievementList[achievementID] == true then
		return
	end

	--iOS
	local showsCompletionBanner = params and params.showsCompletionBanner or true
	local percentComplete = params and params.percentComplete or 100

	local listener = function(event)
		-- update achievement list so that the same achievement is not called twice
		-- Only do this if on Google or percentComplete == 100
		if platform == "GPGS" or (platform == "gameCenter" and percentComplete == 100) then
			achievementList[achievementID] = true
			store()
		end
	end

	if ( gpgs ) then
		-- Submit an achievemnt to Google Play Games Services
		gpgs.achievements.unlock( {listener =listener, achievementId = achievementID} )
	elseif ( gameCenter ) then
		-- Submit an achievemnt to Apple Game Center
		gameCenter.request( "unlockAchievement",
		    {
		        achievement =
		        {
		            identifier = achievementID,
		            percentComplete = percentComplete,
		            showsCompletionBanner = showsCompletionBanner
		        },
		        listener = listener
		    }
		)
	end
end

-- show achievements from the appropriate game network
public.showAchievements = function()
	local listener = function(event)

	end

	if ( gpgs ) then
		-- Show achievemnts for Google Play Games Services
		local params = {reload = true, listener = listener}
		gpgs.achievements.load( params ) -- reloads the list so it is most accurate
		gpgs.achievements.show( listener)
	elseif ( gameCenter ) then
		-- Show achievemnts for Apple Game Center
		gameCenter.show( "achievements", { listener=listener } )
	end
	
end

-- show leaderboard from the appropriate game network
public.showLeaderboard = function(leaderboard)
	local leaderboard = leaderboard and public.leaderBoards[leaderboard][platform] or nil

	--Android
	local friendsOnly = params.friendsOnly or false
	local timeSpan = params.timeSpan or "all time"

	if ( gpgs ) then
	    -- Show a Google Play Games Services leaderboard
	    gpgs.leaderboards.show( {leaderboardId = leaderboard, friendsOnly = friendsOnly, timeSpan = timeSpan} )
	elseif ( gameCenter ) then
	    -- Show an Apple Game Center leaderboard
	    gameCenter.show( "leaderboards",
	    {
	        leaderboard = {
	            category = leaderboard
	        }
	    })
	end
end

-- check score based achievements
-- checks sorted achievements and if the current score is higher than the points submit achievement
public.checkScoreAchievement = function(currentScore)

	for i =1, #sortedAchievements do
		if currentScore >= sortedAchievements[i].points then
			public.submitAchievement(sortedAchievements[i].key)
			return true
		end
	end
end

-- sort score by points
sortAchievements = function()
	for k, v in pairs(public.achievements) do
		if v.points then
			sortedAchievements[#sortedAchievements + 1] = v
			sortedAchievements[#sortedAchievements].key = k
		end
	end
	local function compare( a, b )
    	return a.points > b.points
	end
	table.sort( sortedAchievements, compare )
end



return public