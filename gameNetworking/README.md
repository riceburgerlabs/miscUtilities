# gameNetworking.lua
## Description

Module that allows **Google Play Game Services** or **Game Center** to be accesses through the same piece of code.  Code is added to as author has a need, as such, the code is currently limited to Leaderboard and Achievement based actvities.

## Installing
Download the file. In main.lua require the module and pass over the data file containing achievement and leaderboard data.
```lua
local gameNetwork = require ("scripts.helper.gameNetworking")
gameNetwork.loadData("scripts.helper.gameNetworkingData")
```
For automatic log-in include a call to login within the `applicationStart` `system` event.
```lua
local function onSystemEvent( event ) 
    if ( event.type == "applicationStart" ) then
		gameNetwork.login()
        return true
    end
end
Runtime:addEventListener( "system", onSystemEvent )
```

----------

### Usage
Use each method as follows.

----------

#### Setup

<details>
<summary>loadData() (click to expand)</summary>

## loadData()
### Overview
Loads achievement and leaderboard data from specified file.
### Syntax
`loadData( file )` 

### Parameter Reference
**file (required)** - *path* - path to file containing data

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
<summary>login() (click to expand)</summary>
	
## login()

### Overview

Logs into the either **Google Play Game Services** or **Game Center**.

### Syntax
`login( params )`

### Parameter Reference

**params (optional)** - *table*

----------

#### Generic (work across both Android and iOS)

- **successLoginCallback (optional)** - *function* - will be called when a login attempt succeeds
- **failLogInCallback (optional)** - *function* - will be called when a login attempt fails

#### GPGS (Android)
- **loggedOutCallback (optional)** - *function* - will be called when user logs our
- **userInitiated (optional)** *Boolean* - If `true`, a sign-in dialog will appear if the user is not logged in. Use this when the user specifically wants to log in via a UI button/element instead of being logged in automatically. Default is `false`
</details>

----------

#### Misc

<details>
<summary>returnPlatform() (click to expand)</summary>

## returnPlatform()
### Overview
Returns the current platform.  Good for when you want your main code to execute differently for specific plaforms i.e. loading the right image etc.
### Syntax
`returnPlatform()`
</details>

<details>
<summary>isConnected() (click to expand)</summary>

## isConnected() (GPGS Only)
### Overview
Returns a boolean of `true` if the current user is logged in.
### Syntax
`isConnected()`
</details>

----------

#### Leaderboards

<details>
<summary>submitScore() (click to expand)</summary>

## submitScore()

### Overview

Submits a score to a specific leaderboard on the corresponding platform.

### Syntax
`submitScore( score, leaderboard, params )`

### Parameter Reference

#### Generic (work across both Android and iOS)
**score (required)** - *interger* - The score value.

**leaderboard (required)** - *string* - Reference of the Leaderboard to submit to. Note - this is not the `leaderboardID` that you use with the actual stores, but rather the key given in the data file specified in `loadData()` i.e `bestScore`

#### GPGS (Android)
**params (optional)** - *table*
- **listener** - *function* - Listener function which receives a submit event.
- **tag** - *String*- Optional additional info. Must be  URL-encoded  and a maximum size of 64 bytes.

</details>

<details>
<summary>showLeaderboard() (click to expand)</summary>

## showLeaderboard()

### Overview

Shows a specific leaderboard, or all leaderboards.

### Syntax
`showLeaderboard( leaderboard, params )`

### Parameter Reference

#### Generic (work across both Android and iOS)
**leaderboard (required)** - *string* - Reference of the Leaderboard to show. Note - this is not the `leaderboardID` that you use with the actual stores, but rather the key given in the data file specified in `loadData()` i.e `bestScore`

#### GPGS (Android)
**params (optional)** - *table*
- **friendsOnly  (optional)** *Boolean* - If  `true`, loads only scores for the current player's friends.
- **timeSpan (optional)**  - One of the following values:
	-   `"all time"`  — all scores (default).
	-   `"weekly"`  — scores from the week.
	-   `"daily"`  — scores from the day.

</details>

<details>
<summary>loadScores() (click to expand)</summary>

## loadScores()

### Overview

Retrieves scores from a specified leaderboard.

### Syntax
`loadScores( leaderboard, params )`

### Parameter Reference

----------

#### Generic (work across both Android and iOS)
 **leaderboard (required)** - Leaderboard ID from which to load scores.
 
**params (required)** - *table*

 - **friendsOnly  (optional)** *Boolean* - If  `true`, loads only scores for the current player's friends.
- **timeSpan (optional)**  - One of the following values:
	-   `"all time"`  — all scores (default).
	-   `"weekly"`  — scores from the week.
	-   `"daily"`  — scores from the day.

- **callback (optional)** - Listener function which receives a [oadScores event.

----------
#### GPGS (Android)
- **reload  (optional)** *Boolean* - If  `true`, the data will be retrieved fresh, not from a cache.
- **position  (optional)** One of the following values:
	-   `"top"`  — the top scores (default).
	-   `"single"`  — the current player's score.
	-   `"centered"`  — scores around the current player's score.

- **limit  (optional)** *Number* - Number of scores to load. The maximum and default is  `25`.

----------
#### Game Center (iOS)
**rangeLow** and **rangeHigh** - Optional two integer values. The first value is a start index and the second value is the number of players to retrieve (less than 100). The default range is `{ 1,25 }`

</details>

----------

#### Achievements

<details>
<summary>unlockAchievement() (click to expand)</summary>

## unlockAchievement()

### Overview

Unlocks an achievement.

### Syntax
`unlockAchievement( achievement, params )`

### Parameter Reference

----------

#### Generic (work across both Android and iOS)

**achievement (required)** - *string* - Reference of the Achievement to submit unlock. Note - this is not the `achievementID` that you use with the actual stores, but rather the key given in the data file specified in `loadData()` i.e `A_WAVE_1_COMPLETED`

**params (optional)** - *table*

- **callback (optional)** - *function* - callback function which receives an unlock event.

----------
#### Game Center (iOS)

- **showsCompletionBanner (optional)**  - *boolean* - if set to `true`, will cause Apple to automatically show a completion banner when `percentComplete` reaches `100`
- **percentComplete (optional)** - *interger* -  represents the completion percentage of the achievement. Setting this value to `100` will fully unlock the achievement. If this field is omitted, it's assumed this value is `100`

</details>

<details>
<summary>showAchievements() (click to expand)</summary>

## showAchievements()

### Overview

Shows all achievements.

### Syntax
`showAchievements(  params )`

### Parameter Reference

**params (optional)** - *table*

#### Generic (work across both Android and iOS)

- **listener (optional)** - *function* - Listener function which receives a show event.

----------
#### GPGS (Android)
- **reload (optional)** - *boolean* - If `true` (default) then `load` will be called with a `reload` value of `true` to force it load new values and not cached ones.

</details>

<details>
<summary>checkScoreAchievement() (click to expand)</summary>

## checkScoreAchievement()

### Overview

Checks score values of score based achievements, submits achievement if required..

### Syntax
`checkScoreAchievement( score, orderLargerIsBetter )`

### Parameter Reference

#### Generic (work across both Android and iOS)

**score (required)** - *number* - the score that needs to be checked against achievement list

**orderLargerIsBetter (optional)** - *boolean* - if `true` (default) then it will unlock achievements for scores that are lower than the `score` parameter, if `false` then higher scores will be unlocked.,
</details>

## Built With
* [Corona](https://coronalabs.com/) - Corona SDK

## Authors

* Multiple sources on the Corona forums
* **Rice Burger Labs** - [Rice Burger Labs](http://www.riceburgerlabs.com)

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details

# Acknowledgments
* Big thanks to the Corona community.
