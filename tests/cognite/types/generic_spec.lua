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

	it("instances should be independent", function()
		local Email = Generic({
			__type = "Email",
		})
		local email1 = Email("moo@boo")
		local email2 = Email("boo@moo")
		assert.are_not_same(email1.__raw, email2.__raw)
	end)

	it("could be initialized with __init", function()
		local Email = Generic({
			__type = "Email",
			__init = function(self, value)
				self.user_email = value
			end,
		})
		local email = Email("moo@boo")
		assert.are.equal(email.user_email, "moo@boo")
	end)

	it("should be initialized with validation", function()
		local Email = Generic({
			__type = "ValidatedEmail",
			__validate = function(value)
				if string.match(value, "^.+@.+$") == nil then
					error("Invalid email address, given: " .. value)
				end
				return value
			end,
		})
		local email
		assert.has_no_error(function()
			email = Email("moo@boo.foo")
		end)
		assert.are.same("moo@boo.foo", email.__raw)

		assert.has_error(function()
			Email(42)
		end)
	end)

	it("should be read only", function()
		local Email = Generic({
			__type = "ReadOnlyEmail",
		})
		local email = Email("boo@moo")
		assert.has_error(function()
			email.__raw = "moo@boo"
		end)
	end)
end)
