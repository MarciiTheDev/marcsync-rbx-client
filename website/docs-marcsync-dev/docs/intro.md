---
sidebar_position: 1
---

# Getting Started

Let's install **MarcSync in less than 5 minutes**.

### What you'll need

- [MarcSync Management Account](https://manage.marcsync.api.marcthedev.it)
  - Click the "Login with Discord" button and login with your Discord account.
- [Roblox Studio](https://create.roblox.com/landing) (Windows or Mac):
- [MarcSync Client](https://github.com/MarciiTheDev/marcsync-rbx-client/releases/tag/v1.0.0) Version 1.0.X

## Installing the Client

### 1. Open Roblox Studio

- Open Roblox Studio and create a new place or open an existing one in which you want to use MarcSync in.

### 2. Put in the Client

:::danger Danger

Please only use MarcSync in **ONLY SERVER-READABLE PLACES**. This means that you should only use MarcSync in places that are not accessible by players. If you use MarcSync in a place that is accessible by players, they can easily get your token and modify data in your place. If you think your token has been compromised, please generate a new one in the [MarcSync Management Account](https://manage.marcsync.api.marcthedev.it).

:::

- Drag and drop the downloaded MarcSync Client into the Explorer window in Roblox Studio.
  - If you don't see the Explorer window, click the "View" tab and check the "Explorer" box.
  - You should now see a folder called "MarcSync" in the Explorer window.
- Grab the "MarcSync" folder and drag it into the "ServerScriptService" folder.
  - If you don't see the "ServerScriptService" folder, click the "View" tab and check the "Explorer" box.
  - You should now see a folder called "MarcSync" in the "ServerScriptService" folder.

### 3. Configure the Client

:::caution Warning

Please make sure to **not** share your token with anyone. This token is used to authenticate your place with the MarcSync API and can be used to modify your place. If you think your token has been compromised, please generate a new one in the [MarcSync Management Account](https://manage.marcsync.api.marcthedev.it).

:::

- Open the "MarcSync" folder in the "ServerScriptService" folder.
- Open the MarcSyncv1.0 file in the "MarcSync" folder and search for the following lines:

```lua
local tokens = {
  ["exampleToken"] = "AAAAAAAAAA.BBBBBBBBBB.CCCCCCCCCC"
}
```

- Replace the `AAAAAAAAAA.BBBBBBBBBB.CCCCCCCCCC` with your token from the [MarcSync Management Account](https://manage.marcsync.api.marcthedev.it) and save the file.
- Replace the `exampleToken` with a name for your token. This can be anything you want, but it's recommended to use something that describes the place you're using MarcSync in.

## Implementing MarcSync

:::info Note

Please make sure to enable HTTP requests in your game settings. You can do this by going to the "Game Settings" tab in Roblox Studio and checking the "Allow HTTP Requests" box. This is required for MarcSync to work.

:::

:::danger Danger

Please only use MarcSync in **ONLY SERVER-READABLE PLACES**. This means that you should only use MarcSync in places that are not accessible by players. If you use MarcSync in a place that is accessible by players, they can easily get your token and modify data in your place. If you think your token has been compromised, please generate a new one in the [MarcSync Management Account](https://manage.marcsync.api.marcthedev.it).

:::

### 1. Require MarcSync

First, we need to require MarcSync in our script. We can do this by adding the following line to the top of our script:

```lua
// highlight-start
local MarcSync = require(game:GetService("ServerScriptService"):WaitForChild("MarcSync")["MarcSyncv1.0"])
// highlight-end
```

### 2. Create a new MarcSync instance

Next, we need to create a new MarcSync instance. We can do this by adding the following line to our script:

```lua
local MarcSync = require(game:GetService("ServerScriptService"):WaitForChild("MarcSync")["MarcSyncv1.0"])
// highlight-start
local ms = MarcSync.new("exampleToken")
// highlight-end
```

:::info Note

Make sure to replace `exampleToken` with the name of your token, like we did in the [Configure the Client](#3-configure-the-client) step.

:::

Great! We now have a new MarcSync instance. This instance will be used to communicate with the MarcSync API.

## Example Usage

Here is an example of how you can use MarcSync to store a player's playtime in a MarcSync Database.

```lua
local MarcSync = require(game:GetService("ServerScriptService"):WaitForChild("MarcSync")["MarcSyncv1.0"])
local ms = MarcSync.new("exampleToken")

local activityCollection = ms:getCollection("activities")

local activities = {}

game:GetService("Players").PlayerAdded:Connect(function(plr)

  local activity = activityCollection:getEntries({
		["userId"] = plr.UserId
	})[1]
	
	if not activity then
		activity = activityCollection:createEntry({
			["userId"] = plr.UserId,
			["playTime"] = 0
		})
	end
	
  -- Not required, but just for a visual example

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = plr
	
	local playTime = Instance.new("IntValue")
	playTime.Name = "PlayTime"
	playTime.Parent = leaderstats
	playTime.Value = activity:getValue("playTime")

  -- [[ End of visual example ]]
	
	activities[plr.UserId] = {
    ["activity"] = activity,
    ["joinedAt"] = os.time()
  }
	
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	
	activities[plr.UserId].activity:updateValues({
		["playTime"] = activities[plr.UserId].activity:getValue("playTime") + (os.time() - activities[plr.UserId].joinedAt)
	})
	
end)

-- Not required, but just for a visual example

coroutine.wrap(function()
	while true do
		task.wait(1)
		for i,_ in pairs(activities) do
			game.Players:GetPlayerByUserId(i).leaderstats.PlayTime.Value += 1
		end
	end
end)()

-- [[ End of visual example ]]

```

:::info Note

Please make sure to, if you test out try out that example, to replace `exampleToken` with the name of your token, like we did in the [Configure the Client](#3-configure-the-client) step. As well as either creating the `activities` collection via `ms:createCollection("activities")` or replacing `activities` with an already existing collection.

:::

:::info Note

This is just an example of how you can use MarcSync. You can use MarcSync however you want, as long as you follow the [Terms of Service](https://manage.marcsync.api.marcthedev.it/tos.html).

:::