
local ulmethods = {}
local isUniqueList = function(a)
	return getmetatable(a) == ulmethods
end

local getListOrNil = function(v)
	if isUniqueList(v) then
		return v.list
	elseif type(v) == "table" then
		return v
	else
		return nil
	end
end

local getListOrEmpty = function(v)
	return getListOrNil(v) or {}
end

local getListOrSingleton = function(v)
	return getListOrNil(v) or {v}
end

local coerceToUniqueList = function(v)
	if isUniqueList(v) then
		return v
	else
		return UniqueList(v)
	end
end

local verifyParam = function(self)
	if not isUniqueList(self) then
		error("Expected a UniqueList as the first (or implied) parameter!", 3)
	end
end

local UniqueList = {
	isThisType = isUniqueList;
	insert = function(self, val)
		verifyParam(self)
		if not self.map[val] then
			table.insert(self.list, val)
			self.map[val] = true
			self.count = self.count + 1
		end
	end;
	removeValue = function(self, val)
		verifyParam(self)
		if self.map[val] then
			self.map[val] = nil
			local idx = nil
			for i, v in self.list do
				if v == val then
					idx = i
					break
				end
			end
			assert(idx ~= nil, "This should never happen!")
			table.remove(self.list, idx)
			self.count = self.count - 1
		end
	end;
	iter = function(self)
		verifyParam(self)
		local idx = 0
		return function()
			idx = idx + 1
			if idx > #(self.list) then return nil end
			return self.list[idx]
		end
	end;
	contains = function(self, val)
		verifyParam(self)
		return (self.map[val] == true)
	end;
	get = function(self, idx)
		verifyParam(self)
		return self.list[idx]
	end;
	concat = function(self, delim)
		verifyParam(self)
		return table.concat(self.list, delim)
	end;
}

ulmethods.__add = function(a, b)
	local ret = UniqueList(a) -- copy construct
	for _, v in ipairs(getListOrSingleton(b)) do
		ret:insert(v)
	end
	return ret
end

ulmethods.__sub = function(a, b)
	local ret = UniqueList(a) -- copy construct
	for _, v in ipairs(getListOrSingleton(b)) do
		ret:remove(v)
	end
	return ret
end

ulmethods.__len = function(self)
	return #(self.list)
end

ulmethods.__eq = function(a, b)
	local listA = getListOrEmpty(a)
	local listB = getListOrEmpty(b)
	if #listA ~= #listB then
		return false
	end
	local n = #listA
	for i = 1, n do
		if listA[i] ~= listB[i] then
			return false
		end
	end
	return true
end

ulmethods.__tostring = function(self)
	local ret = {}
	for _, v in ipairs(getListOrNil(self)) do
		table.insert(ret, tostring(v))
	end
	return table.concat({ "[", table.concat(ret, ","), "]" })
end

setmetatable(UniqueList, {
		__call = function(_, inVal)
			local inputVal
			if UniqueList.isThisType(inVal) then
				-- copy constructor, so to speak: pretend they just passed the list.
				inputVal = inVal.list
			else
				inputVal = inVal
			end
			local ret = setmetatable({map = {}, list = {}, count = 0}, ulmethods)

			if type(inputVal) == "table" then
				for _, v in ipairs(inputVal) do
					ret:insert(v)
				end
			elseif inputVal ~= nil then
				ret:insert(inputVal)
			end

			return ret
		end;
		--[=[
	__index = function(...)
		print("DEBUG in __index", ...)
		return nil
		--[[
		if UniqueList.isThisType(self) then
			print("DEBUG in __index", self, key,  self.list[key])
			return self.list[key]
		else
			return nil
		end]]
	end;
	]=]
	})

ulmethods.__index = UniqueList

return UniqueList
