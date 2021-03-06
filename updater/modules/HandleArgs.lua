-- Simple module for doing some command-line processing.
-- Here's some sample code showing how it can be used
--[[
local HandleArgs = require "HandleArgs"

options = {
	["--quiet"] = {
		short = "-q";
		doc = "Silences output.";
		action = function()
			quiet = true
		end;
	};

	["--delete"] = {
		short = "-d";
		doc = "Deletes a misspelling from the database before writing.";
		params = {"misspelling"};
		action = function(t)
			table.insert(todelete, t.misspelling)
		end;
	};

	["--reason"] = {
		short = "-r";
		doc = "Disable automatic replacement of a misspelling by specifying both the misspelling and a quoted reason.";
		params = {"misspelling", "reason"};
		action = function(t)
			table.insert(extralines, ("%s->,%s"):format(t.misspelling, t.reason))
		end;
	};

}

local usage = HandleArgs.createUsage(options, "All additional arguments will be treated as input files.")

if #arg == 0 then
	usage()
end

local files = HandleArgs.process(options)

]]

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

-- Makes sure that all those with a "short" flag are included in the table
-- under it as well.
local expandOptions = function(options)
	-- Must first extract the keys, so we can iterate safely
	-- while modifying "options"
	local names = {}
	for optionName, _ in pairs(options) do
		table.insert(names, optionName)
	end

	for _, optionName in ipairs(names) do
		local optionTable = options[optionName]
		if optionTable.short and not options[optionTable.short] then
			options[optionTable.short] = optionTable
		end
	end
end

local M = {}

-- Returns a function that displays usage information then exits (with
-- code 1 or optionally the code you pass)
--
-- As a side effect, it adds itself to your options table as --help
-- and -h
M.createUsage = function(options, generalInfo, progName)
	local programName = progName or arg[0]
	local usage = function(code)
		expandOptions(options)
		local invertedOptions = {}
		for optionName, optionTable in pairs(options) do
			if invertedOptions[optionTable] then
				table.insert(invertedOptions[optionTable], optionName)
			else
				invertedOptions[optionTable] = { optionName }
			end
		end

		print("\nUsage for " .. programName)
		print()

		if generalInfo then print(generalInfo .. "\n") end

		print("Options:\n")
		for details, flags in pairs(invertedOptions) do
			io.write("  ")
			table.sort(flags)
			io.write(table.concat(flags, ","))
			if details.params and #(details.params) > 0 then
				io.write("  ")
				io.write(table.concat(details.params, "  "):upper())
			end
			io.write("\n    ")
			print(details.doc)
			print()
		end
		if code == nil then
			code = 1
		end
		os.exit(code)
	end


	options["--help"] = {
		short = "-h";
		doc = "Shows this help screen";
		action = usage;
	}
	return usage
end

-- Handles the args passed to your program as specified, returning
-- all un-recognized items in a table in the order they were in the
-- argument table
M.process = function(options, args)
	expandOptions(options)
	local arg = args or arg
	local unhandled = {}
	local idx = 1
	local n = #arg
	while idx <= n do
		local lookup = options[arg[idx]]
		if lookup then
			--print("DEBUG Recognized", arg[idx])
			local params = {}
			if lookup.params and #(lookup.params) > 0 then
				for _, paramname in ipairs(lookup.params) do
					idx = idx + 1
					params[paramname] = arg[idx]
				end
			end
			lookup.action(params)
		else
			--print("DEBUG Didn't recognize", arg[idx])
			table.insert(unhandled, arg[idx])
		end
		idx = idx + 1
	end

	return unhandled
end

return M
