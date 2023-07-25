local AuthorizationError = require(script.Parent.Errors.Authorization)
local CollectionError = require(script.Parent.Errors.Collection)
local EntryError = require(script.Parent.Errors.Entry)

local HttpService = game:GetService("HttpService")

function errorHandler(type: string, resultBody: any, resultObject: {})
	local Error;
	if typeof(resultBody) == typeof({}) and resultBody["message"] then
		Error = resultBody["message"]
	elseif typeof(resultBody) == typeof("") then
		Error = resultBody
	else
		Error = "An Unexpected Error occoured."
	end

	if type == "collection" then
		if resultObject["StatusCode"] == 401 then
			Error = AuthorizationError.InvalidAccessToken("InvalidAccessToken")
		elseif resultObject["StatusCode"] == 404 then
			Error = CollectionError.CollectionNotFound("CollectionNotFound")
		elseif resultObject["StatusCode"] == 400 then
			Error = CollectionError.CollectionAlreadyExists("CollectionAlreadyExists")
		end
	elseif type == "entry" or type == "entryId" then
		if resultObject["StatusCode"] == 401 then
			Error = AuthorizationError.InvalidAccessToken("InvalidAccessToken")
		elseif resultObject["StatusCode"] == 404 then
			Error = CollectionError.CollectionNotFound("CollectionNotFound")
		elseif resultObject["StatusCode"] == 400 then
			Error = EntryError.InvalidEntryData("InvalidEntryData")
		elseif type == "entryId" and ((resultBody["modifiedEntries"] and resultBody["modifiedEntries"] == 0) or (resultBody["deletedEntries"] and resultBody["deletedEntries"] == 0)) then
			Error = EntryError.EntryNotFound("EntryNotFound")
		end
	end

	return {["success"] = false, ["errorMessage"] = Error}
end

local utils = {}

function utils.makeHTTPRequest(type: string, method: string, url: string, body: {}, authorization: string):{["success"]: boolean, ["message"]: string}
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
		if type == "entryId" and ((resultBody["modifiedEntries"] and resultBody["modifiedEntries"] == 0) or (resultBody["deletedEntries"] and resultBody["deletedEntries"] == 0)) then return errorHandler(type, resultBody, resultObj) end
		if resultBody["warning"] then warn('[MarcSync HTTPRequest Handler] MarcSync HTTP Request returned warning for URL "'..url..'" with body: "'..HttpService:JSONEncode(body)..'": '..resultBody["warning"]) end
		return resultBody
	end
	return errorHandler(type, resultBody, resultObj)
end

return utils