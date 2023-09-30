local AuthorizationError = require(script.Parent.Errors.Authorization)
local CollectionError = require(script.Parent.Errors.Collection)
local EntryError = require(script.Parent.Errors.Entry)

local HttpService = game:GetService("HttpService")

function fehlerMisshandlung(type: string, resultBody: any, resultObject: {})
	local Error;
	if typeof(resultBody) == typeof({}) and resultBody["message"] then
		Error = resultBody["message"]
	elseif typeof(resultBody) == typeof("") then
		Error = resultBody
	else
		Error = "Es ist ein unerwarteter Fehler aufgetreten."
	end

	if type == "collection" then
		if resultObject["StatusCode"] == 401 then
			Error = AuthorizationError.InvalidAccessToken("InvalidAccessToken")
		elseif resultObject["StatusCode"] == 404 then
			Error = CollectionError.CollectionNotFound("CollectionNotFound")
		elseif resultObject["StatusCode"] == 400 then
			Error = CollectionError.CollectionAlreadyExists("CollectionAlreadyExists")
		end
	elseif type == "entry" then
		if resultObject["StatusCode"] == 401 then
			Error = AuthorizationError.InvalidAccessToken("InvalidAccessToken")
		elseif resultObject["StatusCode"] == 404 then
			Error = CollectionError.CollectionNotFound("CollectionNotFound")
		elseif resultObject["StatusCode"] == 400 then
			Error = EntryError.InvalidEntryData("InvalidEntryData")
		end
	end

	return {["success"] = false, ["errorMessage"] = Error}
end

local utils = {}

function utils.macheHypertexttransferprotokollAnfrage(type: string, method: string, url: string, body: {}, authorization: string):{["success"]: boolean, ["message"]: string}
	local resultObj;
	local resultBody;
	local success = pcall(function()
		if body then body = HttpService:JSONEncode(body) end
		if (method == "GET" or method == "HEAD") then
			resultObj = HttpService:RequestAsync({Method=method, Url=url, Headers={["Authorization"]=authorization,["Content-Type"]="application/json"}})
			resultBody = HttpService:JSONDecode(resultObj["Body"])
		else
			resultObj = HttpService:RequestAsync({Method=method, Url=url, Headers={["Authorization"]=authorization,["Content-Type"]="application/json"}, Body=body})
			resultBody = HttpService:JSONDecode(resultObj["Body"])
		end
	end)
	if success and resultBody and resultBody["success"] then
		if resultBody["warning"] then warn('[MarkSynchronisation Hypertexttransferprotokoll Misshandler] Die MarcSync-HTTP-Anfrage hat eine Warnung zurückgegeben für die URL "'..url..'" mit Koerper: "'..HttpService:JSONEncode(body)..'": '..resultBody["warning"]) end
		return resultBody
	end
	return fehlerMisshandlung(type, resultBody, resultObj)
end

return utils
