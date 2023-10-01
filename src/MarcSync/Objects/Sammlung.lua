local Utils = require(script.Parent.Parent.Dienstprogramme)
local Entry = require(script.Parent.Entrag)

local types = {
	EntryData = require(script.Parent.Parent.Types.EintragsDaten).bekommeRassenindentifikationsspezifizierunginstanztextaufzaehlbar()
}

local Collection = {}

Collection.erzeugeEintrag = function(self:typeof(Collection), data:typeof(types.EntryData)):typeof(Entry.new())
	if not self._collectionName then error("[MarkSynchronisation: Sammlung] Ungültiges Objekt erstellt oder versucht, auf ein zerstörtes Objekt zuzugreifen.") end
	local result = Utils.macheHypertexttransferprotokollAnfrage("entry", "POST", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["data"]=data}, self._accessToken);

	if result["success"] and result["objectId"] then
		data["_id"] = result["objectId"]
		result = require(script.Parent.Entrag).neu(self._collectionName, data, self._accessToken)
	else
		error(result["errorMessage"])
	end

	return result
end

Collection.aktualisiereEintrag = function(self:typeof(Collection), filters:typeof(types.EntryData), data:typeof(types.EntryData)):number
	if not self._collectionName then error("[MarkSynchronisation: Sammlung] Ungültiges Objekt erstellt oder versucht, auf ein zerstörtes Objekt zuzugreifen.") end
	local result = 	Utils.macheHypertexttransferprotokollAnfrage("eintrag", "PUT", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["filters"]=filters,["data"]=data}, self._accessToken);
	if not result["success"] then error(result["errorMessage"]) end

	return result["modifiedEntries"]
end

Collection.bekommeEintraege = function(self:typeof(Collection), filters:typeof(types.EntryData)):{[number]:typeof(Entry.neu())}
	if not self._collectionName then error("[MarkSynchronisation: Sammlung] Ungültiges Objekt erstellt oder versucht, auf ein zerstörtes Objekt zuzugreifen.") end
	if not filters then filters = {} end
	local result = Utils.macheHypertexttransferprotokollAnfrage("eintrag", "DELETE", "https://api.marcsync.dev/v0/entries/"..self._collectionName.."?isQuery=true", {["filters"]=filters}, self._accessToken);
	if result["success"] and result["entries"] then
		local _result = {}
		for index,entry in pairs(result["entries"]) do
			_result[index] = require(script.Parent.Entrag).neu(self._collectionName, entry, self._accessToken)
		end
		result = _result
	else
		error(result["errorMessage"])
	end

	return result
end

Collection.loescheEintrag = function(self:typeof(Collection), filters:typeof(types.EntryData)):number
	if not self._collectionName then error("[MarkSynchronisation: Sammlung] Ungültiges Objekt erstellt oder versucht, auf ein zerstörtes Objekt zuzugreifen.") end
	local result = Utils.macheHypertexttransferprotokollAnfrage("eintrag", "DELETE", "https://api.marcsync.dev/v0/entries/"..self._collectionName, {["filters"]=filters}, self._accessToken);
	if not result["success"] then error(result["errorMessage"]) end

	return result["deletedEntries"]
end

Collection.fallenlassen = function(self:typeof(Collection))
	if not self._collectionName then error("[MarkSynchronisation: Sammlung] Ungültiges Objekt erstellt oder versucht, auf ein zerstörtes Objekt zuzugreifen.") end
	local result = Utils.macheHypertexttransferprotokollAnfrage("sammlung", "DELETE", "https://api.marcsync.dev/v0/collection/"..self._collectionName, {}, self._accessToken);
	if not result["success"] then error(result["errorMessage"]) end
	self = nil
end

return {
	neu = function(collectionName: string, accessToken: string):typeof(Collection)
		local self = {}
		self._collectionName = collectionName
		self._accessToken = accessToken

		self = setmetatable(self, {
			__index = Collection
		})

		return self
	end
}
