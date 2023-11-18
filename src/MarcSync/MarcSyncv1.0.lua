local tokens = {
	["exampleToken"] = ""
}


-- DO NOT EDIT THE FOLLOWING LINES BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING!

local Utils = require(script.Parent.Dienstprogramme)
local MarcSyncClient = {}

MarcSyncClient.bekommeVersion = function(self:typeof(MarcSyncClient), clientId: number?):string
	self:_checkInstallation()
	local url = ""
	if clientId then url = "/"..clientId end
	local result = Utils.macheHypertexttransferprotokollAnfrage("GET", "https://api.marcsync.dev/v0/utils/version"..url);
	return result["version"]
end

MarcSyncClient.erzeugeSammlung = function(self:typeof(MarcSyncClient), collectionName: string):typeof(require(script.Parent.Objects.Sammlung).new())
	if not self._accessToken then error("[MarkSynchronisation] Bitte legen Sie ein Token fest, bevor Sie MarcSync verwenden.") end
	if not collectionName then error("Kein CollectionName angegeben") end
	local result = Utils.macheHypertexttransferprotokollAnfrage("collection", "POST", "https://api.marcsync.dev/v0/collection/"..collectionName, {}, self._accessToken);

	if not result["success"] then error(result["errorMessage"]) end
	result = require(script.Parent.Objects.Sammlung).neu(collectionName, self._accessToken)

	return result
end
MarcSyncClient.bringeSammlung = function(self:typeof(MarcSyncClient), collectionName: string):typeof(require(script.Parent.Objects.Sammlung).new())
	self:_checkInstallation()
	if not collectionName then error("Kein CollectionName angegeben") end
	local result = Utils.macheHypertexttransferprotokollAnfrage("collection", "GET", "https://api.marcsync.dev/v0/collection/"..collectionName, {}, self._accessToken);
	
	if not result["success"] then error(result["errorMessage"]) end
	result = require(script.Parent.Objects.Sammlung).neu(collectionName, self._accessToken)

	return result
end
MarcSyncClient.bekommeSammlung = function(self:typeof(MarcSyncClient), collectionName: string):typeof(require(script.Parent.Objects.Sammlung).new())
	if typeof(self) ~= "table" then error("Bitte verwenden Sie : anstelle von .") end
	self:_checkInstallation()
	if not collectionName then error("Kein CollectionName angegeben") end
	return require(script.Parent.Objects.Sammlung).neu(collectionName, self._accessToken)
end

return {
	neu = function(accessToken: string):typeof(MarcSyncClient)
		if not accessToken then warn("Beim Erstellen eines neuen MarcSync-Objekts wurde kein Token bereitgestellt.") end
		if not tokens[accessToken] then warn("Token zum Erstellen eines neuen MarcSync-Objekts, das nicht in der Token-Tabelle gefunden wird und stattdessen als Token verwendet wird.") else accessToken = tokens[accessToken] end
		local self = {}
		self._accessToken = accessToken
		self._checkInstallation = function()
			if not self then error("Bitte richten Sie MarcSync ein, bevor Sie MarcSync verwenden.") end
			if not self._accessToken then error("[MarkSynchronisation] Bitte legen Sie ein Token fest, bevor Sie MarcSync verwenden.") end
			--print(HttpService.HttpEnabled)
			--if not HttpService.HttpEnabled then error("Please Enable HTTPService in order to use MarcSync.") end
		end

		self = setmetatable(self, {
			__index = MarcSyncClient
		})

		return self
	end
}
