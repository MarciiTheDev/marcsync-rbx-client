type FilterData = {
	["_startsWith"]: {string},
	["_ignoreCases"]: {string},
	[string]: any
}

return {
	getType = function(): FilterData
		return {}
	end,
}
