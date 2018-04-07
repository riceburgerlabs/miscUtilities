# gameNetworking.lua
## Description

Module that allows **Google Play Game Services** or **Game Center** to be accesses through the same piece of code.

## Installing
Download the file. In main.lua require the module and pass over the data file containing achievement and leaderboard data.
```lua
local gameNetwork = require ("scripts.helper.gameNetworking")
gameNetwork.loadData("scripts.helper.gameNetworkingData")
```
For automatic loggin include a call to login within the `applicationStart` `system` event.
```lua
local function onSystemEvent( event ) 
    if ( event.type == "applicationStart" ) then
		gameNetwork.login()
        return true
    end
end
Runtime:addEventListener( "system", onSystemEvent )
```
### Usage
Use each method as follows.

<details>
<summary>loadData() (click to expand)</summary>

## loadData()
### Overview
Loads achievement and leaderboard data from specified file.
### Syntax
`loadData( file )` 

#### Parameter Reference
**file (required)** - path to file containing data

##### Linked file should take the following format.
 ```lua
 local public = {}

public.leaderBoards = {
	bestScore = {
		GPGS = "fdfsfsfsdfrvevver",
		gameCenter = "com.test.leaderboardname"
	}	
}

public.achievements = {
	A_WAVE_1_COMPLETED = {
		points = 10,
		GPGS = 'dfsdfsfsdfsdss',
		gameCenter = 'com.test.Wave_1_Completed'
	},
	A_50_POINTS = {
		points = 50,
		android = 'dfsfdsfscdscdscs',
		gameCenter = 'com.test.50_POINTS'
	},
	A_DOUBLE_UP = {
		GPGS = 'vsddvsvsv',
		gameCenter = 'com.test.DOUBLE_UP'
	},
	A_Lives_again = {
		GPGS = 'brebrbefbbfdbdfdb',
		gameCenter = 'com.test.LIVES_AGAIN'
	},
}

return public
```

##### Notes
- The key given on each node (e.g. `bestScore` or `A_50_POINTS`) will be the values you will use when submitting or retrieving achievements or scores in your code (see examples below).
- `GPGS = ` and `gameCenter =` expect a string that corresponds to the Achievement or Leaderboard IDs in the corresponding store.
-  `Points` can be used for incremental achievements where points are used. i.e pass over a score or point value to `checkScoreAchievement()` (see notes later) and it will automatically process it and give the appropriate achievement.
</details>

<details>
<summary>returnPlatform() (click to expand)</summary>

## returnPlatform()
### Overview
Returns the current platform
### Syntax
`returnPlatform()`
</details>

<details>
<summary>loadScores() (click to expand)</summary>

## loadScores()

### Overview

Retrieves scores from a specified leaderboard.

### Syntax
`loadScores( params )`

#### Parameter Reference

----------

#### Generic (work across both Android and iOS)
 **leaderboard (required)** - Leaderboard ID from which to load scores.
**friendsOnly  (optional)** *Boolean* - If  `true`, loads only scores for the current player's friends.
**timeSpan (optional)**  - One of the following values:
-   `"all time"`  — all scores (default).
-   `"weekly"`  — scores from the week.
-   `"daily"`  — scores from the day.

**callback (optional)** - Listener function which receives a [loadScores](https://docs.coronalabs.com/plugin/gpgs/leaderboards/event/loadScores/index.html) event.

----------
#### GPGS (Android)
**reload  (optional)** *Boolean* - If  `true`, the data will be retrieved fresh, not from a cache.
**position  (optional)** One of the following values:
-   `"top"`  — the top scores (default).
-   `"single"`  — the current player's score.
-   `"centered"`  — scores around the current player's score.

**limit  (optional)** *Number* - Number of scores to load. The maximum and default is  `25`.

----------
#### Game Center (iOS)
**rangeLow** and **rangeHigh** - Optional two integer values. The first value is a start index and the second value is the number of players to retrieve (less than 100). The default range is `{ 1,25 }`

</details>
