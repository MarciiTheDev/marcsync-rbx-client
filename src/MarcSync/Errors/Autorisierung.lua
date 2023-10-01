return {
    InvalidAccessToken = function(message: string):string
        return ("[MarkSynchronisationsausnahme] InvaliederZugriffsToken: %s"):format(message)
    end
}
