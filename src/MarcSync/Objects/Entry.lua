local Utils = require(script.Parent.Parent.Utils)

local entry = {}
entry.__index = entry

function entry:getValue(value:string):any
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not value then return nil end
	return self._values[value]
end

function entry:getValues():{}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	return self._values
end

function entry:update(newData:{key:any}):{success:boolean,errorMessage:string?,message:string?,modifiedEntries:IntValue?}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("PUT", "https://api.marcsync.dev/v0/entries/"..self._tableId, {["filters"]={["_id"]=self._objectId},["data"]=newData}, self._token)).onResult:Connect(function(any)
		if any["success"] and any["modifiedEntries"] and any["modifiedEntries"] > 0 then
			for i,v in pairs(newData) do
				self._values[i] = v
			end
		end
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

function entry:delete():{success:boolean,errorMessage:string?,message:string?,deletedEntries:IntValue?}
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	local result = nil;
	Utils.handleResponse(Utils.makeHTTPRequest("DELETE", "https://api.marcsync.dev/v0/entries/"..self._tableId, {["filters"]={["_id"]=self._objectId}}, self._token)).onResult:Connect(function(any)
		if any["success"] and any["deletedEntries"] then
			if any["deletedEntries"] < 1 then result = false return end
			spawn(function()
				self = nil
			end)
		end
		result = any
	end)
	repeat
		wait()
	until result ~= nil
	return result
end

function entry._new(_tableId:string, _values:{}, _token:string):typeof(entry)
	if not _tableId or not _values or not _values["_id"] then error("[MarcSync: Entry] Tried creating invalid Entry Object.") end
	local self = setmetatable({}, entry)
	self._tableId = _tableId
	self._values = _values
	self._objectId = _values["_id"]
	self._token = _token
	return self
end

return entry