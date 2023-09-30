return {
    CollectionNotFound = function(message: string):string
		return ("[MarkSynchronisationsausnahme] SammlungNichtGefunden: %s"):format(message)
    end,
    CollectionAlreadyExists = function(message: string):string
		return ("[MarkSynchronisationsausnahme] SammlungExistiertBereits: %s"):format(message)
    end
}
