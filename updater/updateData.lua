#!/usr/bin/env lua

require "strict"
-- Requires lua penlight
local CorrectionDatabase = require "CorrectionDatabase"

data = CorrectionDatabase()

local lastTypos = 0
local lastCorrections = 0
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
	local typos, corrections = data:getCounts()
	print("Current incorrect spelling and corrections counts:")
	print( ("%d [+%d] incorrect spellings, %d [+%d] corrections\n"):format(
			typos,
			typos - lastTypos,
			corrections,
			corrections - lastCorrections)
	)
	lastTypos = typos
	lastCorrections = corrections
end

local f = assert(io.open("outputdict.txt", "wb"))
f:write(data:serialize())
f:close()

