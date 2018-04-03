local public = {}
local defaults = require "scripts.defaults"


local simDevice = "android" -- iOS or android

local waitingM		= require ("scripts.helper.waiting")
local achievementList = table.load( "achievements.json" ) or {}


-- set up environment for either android or game center
local gpgs, gameCenter 
local platform
if onAndroid then
	platform = "android"
	gpgs = require( "plugin.gpgs" )
	gpgs.userInitiated = false
elseif oniOS then
	platform = "iOS"
	gameCenter = require( "gameNetwork" )
else 
	platform = simDevice
end

-- 


local store = function( )
	table.save( achievementList, "achievements.json" )
end 

local sortedAchievements = {}



public.returnIcon = function()
	if onSimulator then
		if simDevice == "iOS" then
			return "gameCenter"
		else
			return "GPGS"
		end
	elseif onAndroid then
		return "GPGS"
	elseif oniOS then
		return "gameCenter"
	end
end

local leaderBoardBest = function()

	if ( gpgs ) then
	-- if not bestScore or bestScore.removeSelf == nil then return end
		local function listener (event)
			if event and event.scores then
				print("highScore is ", event.scores[1].score)
				defaults.updateHighScore("highScore", event.scores[1].score)
			end
		end
		gpgs.leaderboards.loadScores({leaderboardId = "CgkI8er2weIIEAIQAA", reload = true, position = "top", limit = 1, listener = listener} )
	elseif ( gameCenter ) then
		local function requestCallback( event )
	 
		   	table.print_r(event)
		   	--table.print_r(event.data)
		   	print(event.data[1].value)
		   	local score = event and event.data and event.data[1] and event.data[1].value or nil

		   	print (score)
		   	if score then
		   		defaults.updateHighScore("highScore", score)
		   	end
		   	--table.print_r(event.data[1].value)
		    --print("event.localPlayerScore.formattedValue", event.data[1].localPlayerScore.value)
		end
		print("########## loading highscores", leaderboardID)
		gameCenter.request( "loadScores",
	    {
	        leaderboard =
	        {
	            category = "com.riceburgerlabs.braindistraction.bestScore",
	            playerScope = "Global",  -- "Global" or "FriendsOnly"
	            timeScope = "AllTime",   -- "AllTime", "Week", or "Today"
	            range = { 1,5 }
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
   			waitingM.update({text = "Login Unsuccessful", errorMessage = string.first_upper( event.errorMessage .. "." ) })
   			public.failCallback()
   		end
   else
   		
   		if event.name == "login" and event.phase == "logged in" then

   			-- update current highscore to be the same as on gpgs
			leaderBoardBest()
			waitingM.removeWait()

   		elseif event.name == "login" and event.phase == "logged out" then

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
    	leaderBoardBest()
    end
end

local function submitScoreListener( event )
 
    -- Google Play Games Services score submission
    if ( gpgs ) then
 
        if not event.isError then
            -- local isBest = nil
            -- if ( event.scores["daily"].isNewBest ) then
            --     isBest = "a daily"
            -- elseif ( event.scores["weekly"].isNewBest ) then
            --     isBest = "a weekly"
            -- elseif ( event.scores["all time"].isNewBest ) then
            --     isBest = "an all time"
            -- end
            -- if isBest then
            --     -- Congratulate player on a high score
            --     local message = "You set " .. isBest .. " high score!"
            --     native.showAlert( "Congratulations", message, { "OK" } )
            -- else
            --     -- Encourage the player to do better
            --     native.showAlert( "Sorry...", "Better luck next time!", { "OK" } )
            -- end
        end
 
    -- Apple Game Center score submission
    elseif ( gameCenter ) then
 
        if ( event.type == "setHighScore" ) then
            -- Congratulate player on a high score
            -- native.showAlert( "Congratulations", "You set a high score!", { "OK" } )
        else
            -- Encourage the player to do better
            -- native.showAlert( "Sorry...", "Better luck next time!", { "OK" } )
        end
    end
end

-- Public/Access Functions
public.login = function(userInitiated, params)
	public.failCallback = params and params.failCallback or nil
	print("userInitiated", public.userInitiated)
	if onSimulator then 
		print("----- On Simulator So Not Logging In To Game Networking")
		return 
	end
	if ( gpgs ) then
		gpgs.userInitiated = userInitiated or false
	    -- Initialize Google Play Games Services
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

public.submitScore = function (score, leaderboard)
	if not score then return end
	if not leaderboard then 
		for i, v in pairs(public.leaderBoards) do
			leaderboard = i
			break
		end
	end
	leaderboard = public.leaderBoards[leaderboard][platform] or nil
	print("submitting score of ", score , " to ", leaderboard)

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

public.submitAchievement = function(achievementID)
	--print(public.achievements, achievementID, platform)
	--table.print_r(public.achievements)
	achievementID = public.achievements[achievementID][platform] or nil
	--print("Submitting ID", achievementID)
	local listener = function(event)
		table.print_r(event)
	end

	-- check if achievenment has alread been done, if so then return

	if achievementList[achievementID] == true then
		return
	else
		achievementList[achievementID] = true
		--print("adding a new achievemtn to the file")
		store()
	end

	if not achievementID then 
		return
	elseif ( gpgs ) then
		gpgs.achievements.unlock( {listener =listener, achievementId = achievementID} )
	elseif ( gameCenter ) then
		gameCenter.request( "unlockAchievement",
		    {
		        achievement =
		        {
		            identifier = achievementID,
		            percentComplete = 100,
		            showsCompletionBanner = true
		        },
		        listener = listener
		    }
		)
	end
end

public.showAchievements = function()
	local listener = function(event)
		print("showAchievements listener")
		table.print_r(event)
	end
	print("---showAchievements")
	if ( gpgs ) then
		local params = {reload = true, listener = listener}
		gpgs.achievements.load( params )
		gpgs.achievements.show( listener)
	elseif ( gameCenter ) then
		gameCenter.show( "achievements", { listener=listener } )
	end
	
end


public.showLeaderboard = function(leaderboard)
	if not leaderboard then 
		for i, v in pairs(public.leaderBoards) do
			leaderboard = i
			break
		end
	end
	leaderboard = public.leaderBoards[leaderboard][platform] or nil
	
	if ( gpgs ) then
	    -- Show a Google Play Games Services leaderboard
	    gpgs.leaderboards.show( leaderboard )
	 
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

public.checkScoreAchievement = function(currentScore)
	print("Checking Achievemtn for score", currentScore)
	for i =1, #sortedAchievements do
		if currentScore >= sortedAchievements[i].points then
			public.submitAchievement(sortedAchievements[i].key)
			print("achievement successful", sortedAchievements[i].key)

			return true
		end
	end
	print("no achievement")
end


-- Data
public.leaderBoards = {
	bestScore = {
		android = "CgkI8er2weIIEAIQAA",
		iOS =	"com.riceburgerlabs.braindistraction.bestScore"
	}	
}

public.achievements = {
	A_WAVE_1_COMPLETED = {
		points = 10,
		android = 'CgkI8er2weIIEAIQAg',
		iOS = 'com.riceburgerlabs.braindistraction.Wave_1_Completed'
	},
	A_50_POINTS = {
		points = 50,
		android = 'CgkI8er2weIIEAIQBQ',
		iOS = 'com.riceburgerlabs.braindistraction.50_POINTS'
	},
	A_100_POINTS = {
		points = 100,
		android = 'CgkI8er2weIIEAIQBg',
		iOS = 'com.riceburgerlabs.braindistraction.100_POINTS'
	},
	A_250_POINTS = {
		points = 250,
		android = 'CgkI8er2weIIEAIQBw',
		iOS = 'com.riceburgerlabs.braindistraction.250_POINTS'
	},
	A_500_POINTS = {
		points = 500,
		android = 'CgkI8er2weIIEAIQCA',
		iOS = 'com.riceburgerlabs.braindistraction.500_POINTS'
	},
	A_1000_POINTS = {
		points = 1000,
		android = 'CgkI8er2weIIEAIQCQ',
		iOS = 'com.riceburgerlabs.braindistraction.1000_POINTS'
	},
	A_DOUBLE_UP = {
		android = 'CgkI8er2weIIEAIQAw',
		iOS = 'com.riceburgerlabs.braindistraction.DOUBLE_UP'
	},
	A_Lives_again = {
		android = 'CgkI8er2weIIEAIQBA',
		iOS = 'com.riceburgerlabs.braindistraction.LIVES_AGAIN'
	},
}

local sortAchievements = function()
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
sortAchievements()


return public