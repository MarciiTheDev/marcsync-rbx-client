return {
    InvalidEntryData = function(message: string):string
		return ("[MarkSynchronisationsausnahme] InvaliedeEintragsDaten: %s"):format(message)
    end,
    EntryNotFound = function(message: string):string
		return ("[MarkSynchronisationsausnahme] EintragNichtGefunden: %s"):format(message)
    end
}
