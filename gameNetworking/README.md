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
***GPGS (Android)***
**reload  (optional)** *Boolean* - If  `true`, the data will be retrieved fresh, not from a cache.
**position  (optional)** One of the following values:
-   `"top"`  — the top scores (default).
-   `"single"`  — the current player's score.
-   `"centered"`  — scores around the current player's score.

**limit  (optional)** *Number* - Number of scores to load. The maximum and default is  `25`.

----------
***Game Center (iOS)***
**rangeLow** and **rangeHigh** - Optional two integer values. The first value is a start index and the second value is the number of players to retrieve (less than 100). The default range is `{ 1,25 }`

</details>