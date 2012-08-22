
local List = require 'pl.List'
local stringx = require 'pl.stringx'
stringx.import()

local UniqueList = require "UniqueList"

local CorrectionUtils = {}

local isNotEmptyString = function(s) return s ~= "" end
CorrectionUtils.parseLine = function(line)
	local ret = {}
	local incorrect, mapping
	incorrect, mapping = line:match("^(.-)%->(.+)")
	if incorrect == nil or mapping == nil then
		return nil
	else
		ret.incorrect = incorrect:strip()
	end
	mapping = mapping:strip()
	if mapping:find(",") then
		local hasReason
		-- Split text from the right of the "->" on commas, trim whitespace, and skip empty strings
		local parts = mapping:split(","):map(string.strip):filter(isNotEmptyString)
		if not mapping:endswith(",") then
			-- Something after the last comma - must be a "reason"
			ret.reason = parts:pop(#parts)
		end
		ret.corrections = UniqueList(parts)
	else
		ret.corrections = UniqueList{mapping}
	end
	return ret
end

CorrectionUtils.printCorrection = function(parsed)
	print("Incorrect:", parsed.incorrect)
	print("Corrections:", parsed.corrections)
	if parsed.reason ~= nil then
		print("Reason:", parsed.reason)
	end
	print("")
end

CorrectionUtils.serializeCorrection = function(parsed)
	local parsed = CorrectionUtils.validateParsedInput(parsed)

	-- nil is a no-op
	if parsed == nil then return nil end

	local ret = {
		parsed.incorrect,
		"->",
		parsed.corrections:concat(", ")
	}

	if parsed.reason ~= nil then
		table.insert(ret, ", ")
		table.insert(ret, parsed.reason)
	elseif parsed.corrections.count > 1 then
		table.insert(ret, ",")
	end

	return table.concat(ret)
end

local checkCorrections = function(ret)
	local gotOne = false
	for v in ret.corrections:iter() do
		if type(v) ~= "string" then return false end
		gotOne = true
	end
	return gotOne
end

CorrectionUtils.validateParsedInput = function(parsed)
	local ret = parsed
	if type(ret) == "string" then
		ret = CorrectionUtils.parseLine(ret)
	end

	if ret == nil then
		return nil -- no-op if empty or parse error
	end

	if type(ret) ~= "table" then
		print("Warning: Expected a database line or parsed line, got argument of type: " .. type(parsed))
		return nil
	end

	if type(ret.incorrect) ~= "string" or stringx.strip(ret.incorrect) == "" then
		print("Warning: missing/invalid value for 'incorrect spelling' when validating input (" .. tostring(parsed) .. "). Skipping entire entry.")
		return nil
	end

	local result, returnval = pcall(checkCorrections, ret)
	if not result or not returnval then
		print("Warning: missing/invalid value for 'corrections' when validating input (" .. tostring(parsed) .. "). Skipping entire entry.")
		return nil
	end

	if ret.reason ~= nil and type(ret.reason) ~= "string" then
		print("Warning: invalid value for 'reason' when validating input (" .. tostring(parsed) .. ").  Removing 'reason' value: " .. ret.reason)
		ret.reason = nil
	end
	return ret
end

return CorrectionUtils
