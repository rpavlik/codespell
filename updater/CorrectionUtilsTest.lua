#!/usr/bin/env lua
-- Test script for CorrectionUtils.lua which parses and serializes Lua tables
-- storing information on a correction line in a codespell dictionary file.

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

require "strict"

-- Requires lua penlight

-- Try loading luarocks just in case it's needed for dependencies
pcall(require, "luarocks.loader")

-- Looks relative to this file.
local app = require "pl.app"
app.require_here "modules"

local CorrectionUtils = require "CorrectionUtils"
local UniqueList = require "UniqueList"

local assertEqualMember = function(a, b, memberName)
	assert(a[memberName] == b[memberName], ("Non-matching values for member '%s': got '%s', expected '%s'"):format(memberName, tostring(a[memberName]), tostring(b[memberName])))
end

-- Check that a string parses as expected, and that it is accurately maintained
-- when serialized again ("round-tripped")
local doCheck = function(inputString, expectedParsed)
	print("\n\nRunning test for input:")
	print(inputString)
	local parsed = CorrectionUtils.parseLine(inputString)
	assert(parsed, "Failed to parse test string: " .. inputString)
	--CorrectionUtils.printCorrection(parsed)
	assertEqualMember(parsed, expectedParsed, "incorrect")
	assertEqualMember(parsed, expectedParsed, "corrections")
	assertEqualMember(parsed, expectedParsed, "reason")
	local serialized = CorrectionUtils.serializeCorrection(parsed)
	assert(serialized == inputString, ("Expected serialization '%s' but got '%s'"):format(inputString, tostring(serialized)))
end

runSelfTest = function()
	-- Test with a single correction and a reason
	doCheck(
		"clas->class, disabled because of name clash in c++",
		{
			incorrect = "clas";
			corrections = UniqueList{"class"};
			reason = "disabled because of name clash in c++";
		}
	)

	-- Test with a single correction only
	doCheck(
		"abandonned->abandoned",
		{
			incorrect = "abandonned";
			corrections = UniqueList{"abandoned"};
			reason = nil;
		}
	)

	-- Test with multiple corrections
	doCheck(
		"accension->accession, ascension,",
		{
			incorrect = "accension";
			corrections = UniqueList{"accession", "ascension"};
			reason = nil;
		}
	)
end


--[[ MAIN ]]
print "Running self-test"
runSelfTest()
print "Test apparently passed!"

