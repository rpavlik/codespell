#!/usr/bin/env lua
require "strict"
local CorrectionUtils = require "CorrectionUtils"
local UniqueList = require "UniqueList"
local assertEqualMember = function(a, b, memberName)
	assert(a[memberName] == b[memberName], ("Non-matching values for member '%s': got '%s', expected '%s'"):format(memberName, tostring(a[memberName]), tostring(b[memberName])))
end

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
	doCheck(
		"clas->class, disabled because of name clash in c++",
		{
			incorrect = "clas";
			corrections = UniqueList{"class"};
			reason = "disabled because of name clash in c++";
		}
	)

	doCheck(
		"abandonned->abandoned",
		{
			incorrect = "abandonned";
			corrections = UniqueList{"abandoned"};
			reason = nil;
		}
	)

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

