local assert = require("luassert")
local Generic = require("cognite.types.generic")
local log = require("cognite.log")

describe("Generic Type", function()
	it("should have ability different custom types", function()
		local Email = Generic({
			__type = "Email",
		})
		assert.are.equal(Email.__type, "Email")

		local AnotherEmail = Generic({
			__type = "AnotherEmail",
		})
		assert.are_not_equal(Email, AnotherEmail)
		assert.are_not_equal(Email.__type, AnotherEmail.__type)
	end)
end)

describe("Custom Type", function()
	it("should be initialized and return raw value", function()
		local Email = Generic({ __type = "ValuedEmail" })
		-- log.debug("Email:", Email)
		local email = Email("moo@boo.foo")
		-- log.debug("email:", email)
		assert.are.equal(email.__raw, "moo@boo.foo")
	end)

	it("should be initialized with validation", function()
		local Email = Generic({
			__type = "ValidatedEmail",
			__validate = function(value)
				if string.match(value, "^.+@.+$") == nil then
					error("Invalid email address, given: " .. value)
				end
			end,
		})
		-- Email("moo@boo")
		assert.has_no_error(function()
			Email("moo@boo.foo")
		end)
		assert.has_error(function()
			Email(42)
		end)
	end)
end)
