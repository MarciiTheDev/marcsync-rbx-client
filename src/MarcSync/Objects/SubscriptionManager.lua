local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

type CollectionCreatedResponse = {
	DatabaseId: string,
	CollectionName: string,
	Collection: typeof(require(script.Parent.Collection))
}

type CollectionUpdatedResponse = {
	DatabaseId: string,
	oldCollectionName: string,
	newCollectionName: string,
	Collection: typeof(require(script.Parent.Collection))
}

type CollectionDeletedResponse = {
	DatabaseId: string,
	CollectionName: string
}

type DocumentCreatedResponse = {
	DatabaseId: string,
	CollectionName: string,
	DocumentId: string,
	Entry: typeof(require(script.Parent.Entry))
}
type DocumentUpdatedResponse = {
	DatabaseId: string,
	CollectionName: string,
	DocumentId: string,
	oldEntry: typeof(require(script.Parent.Entry)),
	newEntry: typeof(require(script.Parent.Entry))
}

type DocumentDeletedResponse = {
	DatabaseId: string,
	CollectionName: string,
	DocumentId: string,
	Entry: typeof(require(script.Parent.Entry))
}

local subscriptionManager = {}
subscriptionManager.__index = subscriptionManager

function subscriptionManager:onCollectionCreated(callback: (CollectionCreatedResponse) -> ()):RBXScriptConnection
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._token then error("[MarcSync: SubscriptionManager] Invalid Object created or trying to access an destroied object.") end
	local connection = MessagingService:SubscribeAsync("00MarcsyncCollectionCreated", function(message)
		local messageTable = HttpService:JSONDecode(message.Data)
		callback({
			DatabaseId = messageTable[1],
			CollectionName = messageTable[2].CollectionName,
			Collection = require(script.Parent.Collection)._new(messageTable[2].CollectionName, self._token)
		})
	end)
	return self._createRBXScriptConnection(connection)
end

function subscriptionManager:onCollectionDeleted(callback: (CollectionDeletedResponse) -> ()):RBXScriptConnection
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._token then error("[MarcSync: SubscriptionManager] Invalid Object created or trying to access an destroied object.") end
	local connection = MessagingService:SubscribeAsync("00MarcsyncCollectionDeleted", function(message)
		local messageTable = HttpService:JSONDecode(message.Data)
		callback({
			DatabaseId = messageTable[1],
			CollectionName = messageTable[2].CollectionName
		})
	end)
	return self._createRBXScriptConnection(connection)
end

function subscriptionManager:onCollectionUpdated(callback: (CollectionUpdatedResponse) -> ()):RBXScriptConnection
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._token then error("[MarcSync: SubscriptionManager] Invalid Object created or trying to access an destroied object.") end
	local connection = MessagingService:SubscribeAsync("00MarcsyncCollectionUpdated", function(message)
		local messageTable = HttpService:JSONDecode(message.Data)
		callback({
			DatabaseId = messageTable[1],
			oldCollectionName = messageTable[2].oldCollectionName,
			newCollectionName = messageTable[2].newCollectionName,
			Collection = require(script.Parent.Collection)._new(messageTable[2].newCollectionName, self._token)
		})
	end)
	return self._createRBXScriptConnection(connection)
end

function subscriptionManager:onDocumentCreated(callback: (DocumentCreatedResponse) -> ()):RBXScriptConnection
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._token then error("[MarcSync: SubscriptionManager] Invalid Object created or trying to access an destroied object.") end
	local connection = MessagingService:SubscribeAsync("00MarcsyncDocumentCreated", function(message)
		local messageTable = HttpService:JSONDecode(message.Data)
		messageTable[2].DocumentValues = HttpService:JSONDecode(messageTable[2].DocumentValues)
		messageTable[2].DocumentValues._id = messageTable[2].DocumentId
		callback({
			DatabaseId = messageTable[1],
			CollectionName = messageTable[2].CollectionName,
			DocumentId = messageTable[2].DocumentId,
			Entry = require(script.Parent.Entry)._new(messageTable[2].CollectionName, messageTable[2].DocumentValues, self._token)
		})
	end)
	return self._createRBXScriptConnection(connection)
end

function subscriptionManager:onDocumentUpdated(callback: (DocumentUpdatedResponse) -> ()):RBXScriptConnection
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._token then error("[MarcSync: SubscriptionManager] Invalid Object created or trying to access an destroied object.") end
	local connection = MessagingService:SubscribeAsync("00MarcsyncDocumentUpdated", function(message)
		local messageTable = HttpService:JSONDecode(message.Data)
		messageTable[2].oldDocumentValues = HttpService:JSONDecode(messageTable[2].oldDocumentValues)
		messageTable[2].oldDocumentValues._id = messageTable[2].DocumentId
		messageTable[2].newDocumentValues = HttpService:JSONDecode(messageTable[2].newDocumentValues)
		messageTable[2].newDocumentValues._id = messageTable[2].DocumentId
		callback({
			DatabaseId = messageTable[1],
			CollectionName = messageTable[2].CollectionName,
			DocumentId = messageTable[2].DocumentId,
			oldEntry = require(script.Parent.Entry)._new(messageTable[2].CollectionName, messageTable[2].oldDocumentValues, self._token),
			newEntry = require(script.Parent.Entry)._new(messageTable[2].CollectionName, messageTable[2].newDocumentValues, self._token)
		})
	end)
	return self._createRBXScriptConnection(connection)
end

function subscriptionManager:onDocumentDeleted(callback: (DocumentDeletedResponse) -> ()):RBXScriptConnection
	if typeof(self) ~= "table" then error("Please use : instead of .") end
	if not self._token then error("[MarcSync: SubscriptionManager] Invalid Object created or trying to access an destroied object.") end
	local connection = MessagingService:SubscribeAsync("00MarcsyncDocumentDeleted", function(message)
		local messageTable = HttpService:JSONDecode(message.Data)
		messageTable[2].DocumentValues = HttpService:JSONDecode(messageTable[2].DocumentValues)
		messageTable[2].DocumentValues._id = messageTable[2].DocumentId
		callback({
			DatabaseId = messageTable[1],
			CollectionName = messageTable[2].CollectionName,
			DocumentId = messageTable[2].DocumentId,
			Entry = require(script.Parent.Entry)._new(messageTable[2].CollectionName, messageTable[2].DocumentValues, self._token)
		})
	end)
	return self._createRBXScriptConnection(connection)
end

function subscriptionManager._createRBXScriptConnection(subscription: RBXScriptConnection):RBXScriptConnection
	local connection = {}
	connection.Connected = true
	connection.Disconnect = function()
		subscription:Disconnect()
		connection.Connected = false
	end
	return connection
end

function subscriptionManager._new(_token: string)
	local self = setmetatable({}, subscriptionManager)
	self._token = _token
	return self
end

return subscriptionManager
