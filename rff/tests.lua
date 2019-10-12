--[[- Basic testing framework for automated tests.

@module RFF.Tests
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2019

]]
local Tests = {}

local total_tests_run = 0
local total_failures = 0
local logged_warnings = 0
local logged_errors = 0
local assertion_failures = 0
local assertion_count = 0
local current_test = ""

Tests.log = function(text)
    print("RFF.TESTING: " .. current_test .. ": " .. text)
end
do -- modify the logger to track error msg counts 
    local Logger = require(ENV_RFF_PATH .. "interface/logger")
    local warn = Logger.warn
    local error = Logger.error
    Logger.warn = function(text)
        logged_warnings = 1 + logged_warnings
        warn(text)
    end
    Logger.error = function(text)
        logged_errors = 1 + logged_errors
        error(text)
    end
end

function Tests.run(test_name, callback)
    current_test = test_name
    Tests.log("Starting test")
    total_tests_run = 1 + total_tests_run
    local failures = assertion_failures
    local result = callback()
    if result then
        total_failures = 1 + total_failures
        Tests.log("Test failed with result " .. result)
        return
    end
    if assertion_failures > failures then
        total_failures = 1 + total_failures
        Tests.log("Test failed due to assertion failures")
        return
    end
    Tests.log("Test passed")
end

function Tests.assert(result, text, halt)
    assertion_count = 1 + assertion_count
    if not result then
        assertion_failures = 1 + assertion_failures
        Tests.log("Assertion Failed (".. assertion_count.. ")- " .. text)
        if halt then 
            total_failures = 1 + total_failures
            Tests.log("Cancelling further tests.")
            Tests.counts()
            os.exit()
        end
        return true
    end
end
function Tests.counts()
    current_test = "Results"
    Tests.log("Passed: " .. total_tests_run - total_failures .. "/" .. total_tests_run)
    Tests.log("Assertion Errors: " .. assertion_failures .. "/" .. assertion_count)
    Tests.log("Errors: " .. logged_errors)
    Tests.log("Warnings: " .. logged_warnings)
end

function Tests.reset()
    current_test = ""
    total_tests_run = 0
    total_failures = 0
    assertion_failures = 0
    logged_warnings = 0
    logged_errors = 0
    assertion_count = 0
    assertion_failures = 0
end
return Tests
