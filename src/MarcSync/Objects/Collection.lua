local Utils = require(script.Parent.Parent.Utils)
local Entry = require(script.Parent.Entry)

local Types = require(script.Parent.Parent.Types)

local Collection = {}

Collection.createEntry = function(self:typeof(Collection), data:Types.EntryData):typeof(Entry.new())
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = Utils.makeHTTPRequest("entry", "POST", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["data"]=data}, self._accessToken, self._options);
	
	if result["success"] and result["objectId"] then
		data["_id"] = result["objectId"]
		result = require(script.Parent.Entry).new(self._collectionName, data, self._accessToken, self._options)
	else
		error(result["errorMessage"])
	end

	return result
end

Collection.updateEntries = function(self:typeof(Collection), filters:Types.EntryData, data:Types.EntryData):number
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = 	Utils.makeHTTPRequest("entry", "PUT", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["filters"]=filters,["data"]=data}, self._accessToken, self._options);
	if not result["success"] then error(result["errorMessage"]) end

	return result["modifiedEntries"]
end

Collection.getEntries = function(self:typeof(Collection), filters:Types.EntryData):{[number]:typeof(Entry.new())}
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	if not filters then filters = {} end
	local result = Utils.makeHTTPRequest("entry", "DELETE", "https://api.marcsync.dev/v0/entries/"..self._collectionName.."?isQuery=true", {["filters"]=filters}, self._accessToken, self._options);
	if result["success"] and result["entries"] then
		local _result = {}
		for index,entry in pairs(result["entries"]) do
			_result[index] = require(script.Parent.Entry).new(self._collectionName, entry, self._accessToken, self._options)
		end
		result = _result
	else
		error(result["errorMessage"])
	end

	return result
end

Collection.deleteEntries = function(self:typeof(Collection), filters:Types.EntryData):number
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = Utils.makeHTTPRequest("DELETE", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["filters"]=filters}, self._accessToken, self._options);
	if not result["success"] then error(result["errorMessage"]) end

	return result["deletedEntries"]
end

Collection.drop = function(self:typeof(Collection))
	if not self._collectionName then error("[MarcSync: Collection] Invalid Object created or trying to access an destroied object.") end
	local result = Utils.makeHTTPRequest("collection", "DELETE", "https://api.marcsync.dev/v0/collection/"..self._collectionName, {}, self._accessToken, self._options);
	if not result["success"] then error(result["errorMessage"]) end
	self = nil
end

return {
	new = function(collectionName: string, accessToken: string, options: Types.ClientOptions):typeof(Collection)
		local self = {}
		self._collectionName = collectionName
		self._accessToken = accessToken
		self._options = options

		self = setmetatable(self, {
			__index = Collection
		})

		return self
	end
}