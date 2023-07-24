
local tokens = {
	["exampleToken"] = ""
}


-- DO NOT EDIT THE FOLLOWING LINES BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING!

local Utils = require(script.Parent.Utils)

type Function = () -> ()
type DefaultResultType = (success: boolean, errorMessage: string) -> ()
type DefaultResult = {
	["onResult"]: {
		["Connect"]:DefaultResultType
	}
}

local HttpService = game:GetService("HttpService")

function signal()
	local RBXSignal = {}
	RBXSignal._bindableEvent = Instance.new("BindableEvent")
	function RBXSignal:_Fire(...)
		RBXSignal._bindableEvent:Fire(...)
	end
	function RBXSignal:Connect(handler: ({success: boolean, result: {}}) -> ({success: boolean, result: {}}))
		if typeof(self) ~= "table" then error("Please use : instead of .") end
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end
		RBXSignal._bindableEvent.Event:Connect(function(...)
			handler(...)
		end)
	end
	return RBXSignal
end

local MarcSyncClient = {}

MarcSyncClient.getVersion = function(self:typeof(MarcSyncClient), clientId: number?):{["success"]:boolean,["version"]:string,["update_server"]:string}
	self:_checkInstallation()
	local url = ""
	if clientId then url = "/"..clientId end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("GET", "https://api.marcsync.dev/v0/utils/version"..url)).onResult:Connect(function(any)
		result = any
	end)
	repeat
		task.wait()
	until result ~= nil
	return result
end

MarcSyncClient.createCollection = function(self:typeof(MarcSyncClient), collectionName: string):typeof(require(script.Parent.Objects.Collection))
	if not self._accessToken then error("[MarcSync] Please set a Token before using MarcSync.") end
	if not collectionName then error("No CollectionName Provided") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("POST", "https://api.marcsync.dev/v0/collection/"..collectionName, {}, self._accessToken)).onResult:Connect(function(any)
		if not any["success"] then result = false return end
		result = require(script.Parent.Objects.Collection)._new(collectionName, self._accessToken)
	end)
	repeat
		task.wait()
	until result ~= nil
	return result
end
MarcSyncClient.fetchCollection = function(self:typeof(MarcSyncClient), collectionName: string):typeof(require(script.Parent.Objects.Collection))
	self:_checkInstallation()
	if not collectionName then error("No CollectionName Provided") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("GET", "https://api.marcsync.dev/v0/collection/"..collectionName, {}, self._accessToken)).onResult:Connect(function(any)
		if not any["success"] then result = false return end
		result = require(script.Parent.Objects.Collection)._new(collectionName, self._accessToken)
	end)
	repeat
		task.wait()
	until result ~= nil
	return result
end
MarcSyncClient.getCollection = function(self:typeof(MarcSyncClient), collectionName: string):typeof(require(script.Parent.Objects.Collection))
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	self:_checkInstallation()
	if not collectionName then error("No CollectionName Provided") end
	return require(script.Parent.Objects.Collection)._new(collectionName, self._accessToken)
end

return function(accessToken: string):typeof(MarcSyncClient)
	if not accessToken then warn("Token not provided while creating a new MarcSync Object.") end
	if not tokens[accessToken] then warn("Token provided for creating a new MarcSync Object not Found in Token Table, using it as token instead.") else accessToken = tokens[accessToken] end
	local self = setmetatable({}, MarcSyncClient)
	self._accessToken = accessToken
	self._checkInstallation = function()
		if not self then error("Please Setup MarcSync before using MarcSync.") end
		if not self._accessToken then error("[MarcSync] Please set a Token before using MarcSync.") end
		--print(HttpService.HttpEnabled)
		--if not HttpService.HttpEnabled then error("Please Enable HTTPService in order to use MarcSync.") end
	end
	self._errorHandler = function(RBXSignal: {}, Error: string)
		task.spawn(function()
			RBXSignal:_Fire({
				["success"] = false,
				["errorMessage"] = Error
			})
		end)
		return {["onResult"] = RBXSignal}
	end
	self._requestHandler = function(result: {}, Error: string):{["onResult"]: {}}
		if result == nil then return self._errorHandler(signal(), Error) end
		local errorResult;
		local signalevent;
		if #result.Body == 0 and not result.Success then
			errorResult = "HTTP "..result.StatusCode.." ("..result.StatusMessage..")" result = false
		elseif not pcall(function() HttpService:JSONDecode(result.Body) end) then
			error("Unexpected MarcSync Result.")
		else
			result = result.Body
			signalevent = {["onResult"]=signal()}
		end
		task.spawn(function()
			if not result then return end
			signalevent.onResult:_Fire(result)
		end)
		return signalevent or self._errorHandler(signal(), errorResult)
	end

	return self
end