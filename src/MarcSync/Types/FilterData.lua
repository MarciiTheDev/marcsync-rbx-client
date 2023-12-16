type FilterData = {
	["_startsWith"]: {
		[string]: any	
	},
	["_ignoreCases"]: {
		[string]: any
	},
	[string]: any
}

return {
	getType = function(): FilterData
		return {}
	end,
}