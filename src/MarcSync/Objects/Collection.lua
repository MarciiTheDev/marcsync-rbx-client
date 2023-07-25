local HttpService = game:GetService("HttpService")
local Utils = require(script.Parent.Parent.Utils)
local Entry = require(script.Parent.Entry)

local types = {
	EntryData = require(script.Parent.Parent.Types.EntryData).getType()
}

local Collection = {}

Collection.createEntry = function(self:typeof(Collection), data:typeof(types.EntryData)):typeof(Entry.new())
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = Utils.makeHTTPRequest("entry", "POST", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["data"]=data}, self._accessToken);
	
	if result["success"] and result["objectId"] then
		data["_id"] = result["objectId"]
		result = require(script.Parent.Entry).new(self._collectionName, data, self._accessToken)
	else
		error(result["errorMessage"])
	end

	return result
end

Collection.updateEntries = function(self:typeof(Collection), filters:typeof(types.EntryData), data:typeof(types.EntryData)):number
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = 	Utils.makeHTTPRequest("entry", "PUT", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["filters"]=filters,["data"]=data}, self._accessToken);
	if not result["success"] then error(result["errorMessage"]) end

	return result["modifiedEntries"]
end

Collection.getEntries = function(self:typeof(Collection), filters:typeof(types.EntryData)):{[number]:typeof(Entry.new())}
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	if not filters then filters = {} end
	local result = Utils.makeHTTPRequest("entry", "DELETE", "https://api.marcsync.dev/v0/entries/"..self._collectionName.."?isQuery=true", {["filters"]=filters}, self._accessToken);
	if result["success"] and result["entries"] then
		local _result = {}
		for index,entry in pairs(result["entries"]) do
			_result[index] = require(script.Parent.Entry).new(self._collectionName, entry, self._accessToken)
		end
		result = _result
	else
		error(result["errorMessage"])
	end

	return result
end

Collection.deleteEntries = function(self:typeof(Collection), filters:typeof(types.EntryData)):number
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = Utils.makeHTTPRequest("DELETE", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["filters"]=filters}, self._accessToken);
	if not result["success"] then error(result["errorMessage"]) end

	return result["deletedEntries"]
end

Collection.drop = function(self:typeof(Collection))
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = Utils.makeHTTPRequest("collection", "DELETE", "https://api.marcsync.dev/v0/collection/"..self._collectionName, {}, self._accessToken);
	if not result["success"] then error(result["errorMessage"]) end
	self._collectionName = nil
	self._accessToken = nil
end

return {
	new = function(collectionName: string, accessToken: string):typeof(Collection)
		local self = {}
		self._collectionName = collectionName
		self._accessToken = accessToken

		self = setmetatable(self, {
			__index = Collection
		})

		return self
	end
}