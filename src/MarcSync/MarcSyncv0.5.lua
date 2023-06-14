
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

local reqQueue = {}

coroutine.wrap(function()
	while wait(5) do
		for i,v in pairs(reqQueue) do
			local result;
			local success, Error = pcall(function() result = v.method(v.arguments) end)
			if not success and Error == "Number of requests exceeded limit" then
				break
			else
				v.event:__Fire(result)
				table.remove(reqQueue, i)
			end
		end
	end
end)

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

local marcsync = {}
marcsync.__index = marcsync
marcsync.request = {}
function marcsync.new(token: string)
	if not token then warn("Token not provided while creating a new MarcSync Object.") end
	if not tokens[token] then warn("Token provided for creating a new MarcSync Object not Found in Token Table, using it as token instead.") else token = tokens[token] end
	local self = setmetatable({}, marcsync)
	self._token = token
	self.request._parent = self
	self.request.version._parent = self.request
	self.request.database._parent = self.request
	self.request.collection._parent = self.request
	self.utils._parent = self
	return self
end

function marcsync:_checkInstallation()
	if not self then error("Please Setup MarcSync before using MarcSync.") end
	if not self._token then error("[MarcSync] Please set a Token before using MarcSync.") end
	--print(HttpService.HttpEnabled)
	--if not HttpService.HttpEnabled then error("Please Enable HTTPService in order to use MarcSync.") end
end

function marcsync._errorHandler(RBXSignal: {}, Error: string)
	spawn(function()
		RBXSignal:_Fire({
			["success"] = false,
			["errorMessage"] = Error
		})
	end)
	return {["onResult"] = RBXSignal}
end

function marcsync:_requestHandler(result: {}, Error: string):{["onResult"]: {}}
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
	spawn(function()
		if not result then return end
		signalevent.onResult:_Fire(result)
	end)
	return signalevent or self._errorHandler(signal(), errorResult)
end

marcsync.request.version = {}
function marcsync.request.version:get(clientId: number?):{["success"]:boolean,["version"]:string,["update_server"]:string}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._parent then error("[MarcSync] Please set a Token before using MarcSync.") end
	self._parent._parent:_checkInstallation()
	local url = ""
	if clientId then url = "/"..clientId end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("GET", "https://api.marcsync.dev/v0/utils/version"..url)).onResult:Connect(function(any)
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

marcsync.request.collection = {}
function marcsync.request.collection:create(collectionName: string):typeof(require(script.Parent.Objects.Collection))
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._parent then error("[MarcSync] Please set a Token before using MarcSync.") end
	self._parent._parent:_checkInstallation()
	if not collectionName then error("No CollectionName Provided") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("POST", "https://api.marcsync.dev/v0/collection/"..collectionName, {}, self._parent._parent._token)).onResult:Connect(function(any)
		if not any["success"] then result = false return end
		result = require(script.Parent.Objects.Collection)._new(collectionName, self._parent._parent._token)
	end)
	repeat
		wait()
	until result ~= nil
	return result
end
function marcsync.request.collection:fetch(collectionName: string):typeof(require(script.Parent.Objects.Collection))
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._parent then error("[MarcSync] Please set a Token before using MarcSync.") end
	self._parent._parent:_checkInstallation()
	if not collectionName then error("No CollectionName Provided") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("GET", "https://api.marcsync.dev/v0/collection/"..collectionName, {}, self._parent._parent._token)).onResult:Connect(function(any)
		if not any["success"] then result = false return end
		result = require(script.Parent.Objects.Collection)._new(collectionName, self._parent._parent._token)
	end)
	repeat
		wait()
	until result ~= nil
	return result
end
function marcsync.request.collection:get(collectionName: string):typeof(require(script.Parent.Objects.Collection))
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._parent then error("[MarcSync] Please set a Token before using MarcSync.") end
	self._parent._parent:_checkInstallation()
	if not collectionName then error("No CollectionName Provided") end
	return require(script.Parent.Objects.Collection)._new(collectionName, self._parent._parent._token)
end
marcsync.request.database = {}
function marcsync.request.database:fetch(databaseId: number):DefaultResult
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._parent then error("[MarcSync] Please set a Token before using MarcSync.") end
	self._parent._parent:_checkInstallation()
	if not databaseId then error("No DatabaseId Provided") end
	local result;
	local success, Error = pcall(function() result = HttpService:RequestAsync({Url = "https://api.marcthedev.it/marcsync/v0/database/"..databaseId, Headers = {["Authorization"]=self._parent._parent._token}}) end)
	return self._parent._parent:_requestHandler(result, Error)
end
function marcsync.request.database:delete(databaseId: number):DefaultResult
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._parent then error("[MarcSync] Please set a Token before using MarcSync.") end
	self._parent._parent:_checkInstallation()
	if not databaseId then error("No DatabaseId Provided") end
	local result;
	local success, Error = pcall(function() result = HttpService:RequestAsync({Url = "https://api.marcthedev.it/marcsync/v0/database/"..databaseId, Headers = {["Authorization"]=self._parent._parent._token}}) end)
	return self._parent._parent:_requestHandler(result, Error)
end
marcsync.utils = {}
function marcsync.utils.safeRequest(method: Function, arguments: {})
	--_checkInstallation()
	
	
	--[[
	spawn(function()
		local result;
		local success, Error = pcall(function() result = method(arguments) end)
		if not success and Error == "Number of requests exceeded limit" then
			reqQueue[#reqQueue] = {["method"] = method, ["arguments"] = arguments, ["event"] = RBXSignal}
		elseif success then
			RBXSignal:__Fire(result)
		end
	end)
	
	return { ["onResult"] = RBXSignal}
	--]]
end
function marcsync.utils.bulkRequest(methods: {}, safeReq: boolean?):{}
	--_checkInstallation()
	local returns = {}
	for i,method in pairs(methods) do if safeReq then marcsync.safeRequest(method[1], method[2]).onResult:Connect(function(result) returns[i] = result end) else returns[i] = method[1](method[2]) end end
	while #methods ~= #returns do
		wait()
	end
	return returns
end

return marcsync