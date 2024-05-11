local AuthorizationError = require(script.Parent.Errors.Authorization)
local CollectionError = require(script.Parent.Errors.Collection)
local EntryError = require(script.Parent.Errors.Entry)

local HttpService = game:GetService("HttpService")
local Types = require(script.Parent.Types)

function errorHandler(callInformation: {}, resultBody: any, resultObject: {}, retryCount: number)
	local Error;
	if typeof(resultBody) == typeof({}) and resultBody["message"] then
		Error = resultBody["message"]
	elseif typeof(resultBody) == typeof("") then
		Error = resultBody
	else
		Error = "An Unexpected Error occoured."
	end

	local statusCode = resultObject["StatusCode"]
	if callInformation.type == "collection" then
		if statusCode == 401 then
			Error = AuthorizationError.InvalidAccessToken("InvalidAccessToken")
		elseif statusCode == 404 then
			Error = CollectionError.CollectionNotFound("CollectionNotFound")
		elseif statusCode == 400 then
			Error = CollectionError.CollectionAlreadyExists("CollectionAlreadyExists")
		end
	elseif callInformation.type == "entry" then
		if statusCode == 401 then
			Error = AuthorizationError.InvalidAccessToken("InvalidAccessToken")
		elseif statusCode == 404 then
			Error = CollectionError.CollectionNotFound("CollectionNotFound")
		elseif statusCode == 400 then
			Error = EntryError.InvalidEntryData("InvalidEntryData")
		end
	end

	if(statusCode ~= 400 and statusCode ~= 401) then
		if retryCount > 0 then
			warn("[MarcSync HTTPRequest Handler] MarcSync HTTP Request failed with error: "..Error.." and status code: "..statusCode..". Retrying Request. ("..retryCount..") retries left")
			task.wait(3)
			return require(script.Parent.Utils).makeHTTPRequest(callInformation.type, callInformation.method, callInformation.url, callInformation.body, callInformation.authorization, {retryCount = retryCount - 1})
		end
	end

	return {["success"] = false, ["errorMessage"] = Error}
end

local utils = {}

function utils.makeHTTPRequest(type: string, method: string, url: string, body: {}, authorization: string, options: Types.ClientOptions):{["success"]: boolean, ["message"]: string}
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
		if resultBody["warning"] then warn('[MarcSync HTTPRequest Handler] MarcSync HTTP Request returned warning for URL "'..url..'" with body: "'..HttpService:JSONEncode(body)..'": '..resultBody["warning"]) end
		return resultBody
	end
	return errorHandler({
		type = type,
		method = method,
		url = url,
		body = body,
		authorization = authorization
	}, resultBody, resultObj, options.retryCount)
end

return utils