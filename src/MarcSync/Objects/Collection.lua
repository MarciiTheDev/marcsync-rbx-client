local Utils = require(script.Parent.Parent.Utils)
local Entry = require(script.Parent.Entry)

local collection = {}
collection.__index = collection

local filterSheme = {
	["values"]=typeof({ ["key"]=... }),
	["startsWith"]=typeof({ "key" }),
	["ignoreCases"]=typeof({ "key" })
}

function collection:insert(data:{key:any}):typeof(Entry)?
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("POST", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["data"]=data}, self._token)).onResult:Connect(function(any)
		if any["success"] and any["objectId"] then
			data["_id"] = any["objectId"]
			result = require(script.Parent.Entry)._new(self._collectionName, data, self._token)
			return
		end
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

function collection:update(filters:typeof(filterSheme),data:{key:any}):{message:string?,errorMessage:string?,success:boolean,modifiedEntries:number?}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = nil;
	if not filters.values then error("[MarcSync: Collection] Invalid arguments given for collection:select(). Expected filters.values, got nil") end
	filters.values["_startsWith"] = filters.startsWith or {}
	filters.values["_ignoreCases"] = filters.ignoreCases or {}
	Utils.handleResponse(Utils.makeHTTPRequest("PUT", "https://api.marcsync.dev/v1/entries/"..self._collectionName, {["filters"]=filters.values,["data"]=data}, self._token)).onResult:Connect(function(any)
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

function collection:select(filters:typeof(filterSheme),limit:number):{entries:{a:typeof(Entry)?,b:typeof(Entry)?,c:typeof(Entry)?}?,success:boolean,message:string?,errorMessage:string?}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = nil;
	if not filters.values then error("[MarcSync: Collection] Invalid arguments given for collection:select(). Expected filters.values, got nil") end
	filters.values["_startsWith"] = filters.startsWith or {}
	filters.values["_ignoreCases"] = filters.ignoreCases or {}
	Utils.handleResponse(Utils.makeHTTPRequest("PATCH", "https://api.marcsync.dev/v1/entries/"..self._collectionName.."?methodOverwrite=GET", {["filters"]=filters.values, ["limit"]=limit}, self._token)).onResult:Connect(function(any)
		if any["success"] and any["entries"] then
			local _result = {["entries"]={},["success"]=true}
			for index,entry in pairs(any["entries"]) do
				_result["entries"][index] = require(script.Parent.Entry)._new(self._collectionName, entry, self._token)
			end
			result = _result
			return
		end
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

function collection:delete(filters:typeof(filterSheme)):{message:string?,errorMessage:string?,success:boolean,deletedEntries:number?}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = nil;
	if not filters.values then error("[MarcSync: Collection] Invalid arguments given for collection:select(). Expected filters.values, got nil") end
	filters.values["_startsWith"] = filters.startsWith or {}
	filters.values["_ignoreCases"] = filters.ignoreCases or {}
	Utils.handleResponse(Utils.makeHTTPRequest("DELETE", "https://api.marcsync.dev/v1/entries/"..self._collectionName, {["filters"]=filters.values}, self._token)).onResult:Connect(function(any)
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

function collection:drop():{success:boolean,message:string?,errorMessage:string?}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("DELETE", "https://api.marcsync.dev/v0/collection/"..self._collectionName, {}, self._token)).onResult:Connect(function(any)
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

collection._collectionName = nil

function collection._new(_collectionName: string, _token: string):typeof(collection)
	local self = setmetatable({}, collection)
	self._collectionName = _collectionName
	self._token = _token
	return self
end

return collection