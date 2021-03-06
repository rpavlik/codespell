-- Data structure to store zero or more correction line structures, with
-- merging of duplicates and serialization in a deterministic (sorted)
-- order.

--[[ Original Author: Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
Copyright 2012 Iowa State University.
Distributed under the Boost Software License, Version 1.0.

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
]]

local UniqueList = require "UniqueList"
local CorrectionUtils = require "CorrectionUtils"
local bininsert = require "bininsert"
local stringx = require 'pl.stringx'
stringx.import()

local mostlyCaseInsensitiveCompare = function(a, b)
	local al = a:lower()
	local bl = b:lower()
	if al == bl then return a < b end
	return al < bl
end

local mergemarker = " ---- "

local datamethods = {
	add = function(self, parsed)
		-- Make sure our input is what we want
		local parsed = CorrectionUtils.validateParsedInput(parsed)

		if parsed == nil then
			return -- no-op
		end

		-- Look up the current value for this incorrect spelling
		local existing = self[parsed.incorrect]

		if existing == nil then
			-- Brand new correction - easy out.
			self[parsed.incorrect] = parsed
			return
		end

		-- Merging entry with what we had: set union for corrections, and handling reasons.
		existing.corrections = existing.corrections + parsed.corrections -- Set union

		if parsed.reason ~= nil and parsed.reason ~= "" then
			--- OK, we were handed a reason.  Is this an easy case or a hard case (merge)?
			if existing.reason == parsed.reason or existing.reason == nil or #(existing.reason) == 0 then
				-- Easy case - empty or same, so just assign
				existing.reason = parsed.reason
			else
				-- Hard case - warn and concatenate in an ugly way
				print("Warning: Merge of two reasons for " .. existing.incorrect .. ":", existing.reason, parsed.reason)
				print("Merged marked by '" .. mergemarker .. "'")
				existing.reason = existing.reason .. mergemarker .. parsed.reason
			end
		end
	end;

	delete = function(self, incorrect)
		if self[incorrect:strip()] then
			self[incorrect:strip()] = nil
		end
	end;

	sortedIter = function(self)
		local keys = {}
		for k, _ in pairs(self) do
			bininsert(keys, k, mostlyCaseInsensitiveCompare)
		end
		local n = #keys
		local i = 1
		return function()
			if i > n then return nil end
			local key = keys[i]
			i = i + 1
			return self[key]
		end
	end;

	serialize = function(self)
		local ret = {}
		for correction in self:sortedIter() do
			local str = CorrectionUtils.serializeCorrection(correction)
			if str ~= nil then
				table.insert(ret, str)
			end
		end
		table.insert(ret, "") -- for a trailing newline
		return table.concat(ret, "\n")
	end;

	getCounts = function(self)
		local incorrects = 0
		local fixes = 0
		for _, val in pairs(self) do
			incorrects = incorrects + 1
			fixes = fixes + val.corrections.count
		end
		return incorrects, fixes
	end;
}

datamethods.__index = datamethods

return function() -- CorrectionDatabase
	return setmetatable({}, datamethods)
end
