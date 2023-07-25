return {
    InvalidEntryData = function(message: string):string
        return ("[MarcSync Exception] InvalidEntryData: %s"):format(message)
    end,
    EntryNotFound = function(message: string):string
        return ("[MarcSync Exception] EntryNotFound: %s"):format(message)
    end
}