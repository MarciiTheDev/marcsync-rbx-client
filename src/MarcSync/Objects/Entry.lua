local Utils = require(script.Parent.Parent.Utils)

local types = {
	EntryData = require(script.Parent.Parent.Types.EntryData).getType()
}

local Entry = {}

Entry.getValue = function(self:typeof(Entry), key:string):any
	if not key then return nil end
	return self._entryData[key]
end

Entry.getValues = function(self:typeof(Entry)):typeof(types.EntryData)
	return self._entryData
end

Entry.updateValues = function(self:typeof(Entry), data:typeof(types.EntryData)):number
	local result = Utils.makeHTTPRequest("entry", "PUT", "https://api.marcsync.dev/v0/entries/"..self._tableId, {["filters"]={["_id"]=self._objectId},["data"]=data}, self._accessToken);
	
	if result["success"] and result["modifiedEntries"] and result["modifiedEntries"] > 0 then
		for i,v in pairs(data) do
			self._entryData[i] = v
		end
	elseif not result["success"] then
		error(result["errorMessage"])
	end

	return result["modifiedEntries"]
end

Entry.delete = function(self:typeof(Entry))
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	local result = Utils.makeHTTPRequest("entry", "DELETE", "https://api.marcsync.dev/v0/entries/"..self._tableId, {["filters"]={["_id"]=self._objectId}}, self._accessToken);
	
	if not result["success"] then error(result["errorMessage"]) end
	self = nil

end

return {
	new = function(tableId:string, entryData:typeof(types.EntryData), accessToken:string):typeof(Entry)
		if not tableId or not entryData or not entryData["_id"] or not accessToken then error("[MarcSync: Entry] Tried creating invalid Entry Object.") end
		local self = {}
		self._tableId = tableId
		self._entryData = entryData
		self._objectId = entryData["_id"]
		self._accessToken = accessToken

		self = setmetatable(self, {
			__index = Entry
		})

		return self
	end
}