local HttpService = game:GetService("HttpService")

function errorHandler(RBXSignal: {}, result: any)
	local Error;
	if typeof(result) == typeof({}) and result["message"] then
		Error = result["message"]
	elseif typeof(result) == typeof("") then
		Error = result
	else
		Error = "An Unexpected Error occoured."
	end
	spawn(function()
		RBXSignal:_Fire({
			["success"] = false,
			["errorMessage"] = Error
		})
	end)
	return {["onResult"] = RBXSignal}
end

local utils = {}
function utils._signal()
	local RBXSignal = {}
	RBXSignal._bindableEvent = Instance.new("BindableEvent")
	function RBXSignal:_Fire(...)
		RBXSignal._bindableEvent:Fire(...)
	end
	function RBXSignal:Connect(handler: ({success: boolean, result: {}}) -> ({success: boolean, result: {}}))
		if typeof(self) ~= "table" then error("Please use : instead of .") end
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end
		RBXSignal._bindableEvent.Event:Connect(function(...)
			handler(...)
		end)
	end
	return RBXSignal
end
function utils.handleResponse(result: any, error: boolean, signal: RBXScriptSignal?)
	if error then return result end
	spawn(function()
		signal:_Fire(result)
	end)
	return {["onResult"] = signal}
end

function utils.makeHTTPRequest(method: string, url: string, body: {}, authorization: string):{["success"]: boolean, ["message"]: string}
	local result;
	local success = pcall(function()
		if body then body = HttpService:JSONEncode(body) end
		if (method == "GET" or method == "HEAD") then
			result = HttpService:JSONDecode(HttpService:RequestAsync({Method=method, Url=url, Headers={["Authorization"]=authorization,["Content-Type"]="application/json"}})["Body"])
		else
			result = HttpService:JSONDecode(HttpService:RequestAsync({Method=method, Url=url, Headers={["Authorization"]=authorization,["Content-Type"]="application/json"}, Body=body})["Body"])
		end
	end)
	if success and result and result["success"] then
		if result["warning"] then warn('[MarcSync HTTPRequest Handler] MarcSync HTTP Request returned warning for URL "'..url..'" with body: "'..HttpService:JSONEncode(body)..'": '..result["warning"]) end
		return result, false, utils._signal()
	end
	return errorHandler(utils._signal(), result), true
end

return utils