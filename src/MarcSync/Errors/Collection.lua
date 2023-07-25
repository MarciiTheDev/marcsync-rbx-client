return {
    CollectionNotFound = function(message: string):string
        return ("[MarcSync Exception] CollectionNotFound: %s"):format(message)
    end,
    CollectionAlreadyExists = function(message: string):string
        return ("[MarcSync Exception] CollectionAlreadyExists: %s"):format(message)
    end
}