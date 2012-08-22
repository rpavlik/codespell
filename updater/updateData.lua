#!/usr/bin/env lua

require "strict"
-- Requires lua penlight
local CorrectionDatabase = require "CorrectionDatabase"

data = CorrectionDatabase()

for _, fn in ipairs(arg) do
	print("Loading file", fn)
	local f = assert(io.open(fn, "r"))
	for line in f:lines() do
		--[[local parsed = CorrectionUtils.parseLine(line)
		CorrectionUtils.printCorrection(parsed)
		print(CorrectionUtils.serializeCorrection(parsed))]]
		data:add(line)
	end
	f:close()
	print("Current incorrect spelling and corrections counts:", data:getCounts())
	print("\n")
end

local f = assert(io.open("outputdict.txt", "wb"))
f:write(data:serialize())
f:close()

