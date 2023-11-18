return {
    InvalidAccessToken = function(message: string):string
        return ("[MarcSync Exception] InvalidAccessToken: %s"):format(message)
    end
}