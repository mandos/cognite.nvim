local assert = require("luassert")

local elog = function(value)
	require("cognite.log").debug(value)
	assert.is_true(false)
end
local Struct = require("cognite.types.struct")

describe("Struct", function()
	it("should generate custom type", function()
		local dummy = Struct("Dummy", {
			foo = "string",
			bar = "number",
			baz = "boolean",
		})
		assert.is_same("table", type(dummy))
		assert.is_same("Dummy", dummy.__type)
	end)
end)

describe("Custom Struct", function()
	local Dummy = Struct("Dummy", {
		foo = "string",
		bar = "number",
		baz = "boolean",
	})

	it("should be initialize with correct values", function()
		local dummy = Dummy({
			foo = "foo",
			bar = 1,
			baz = true,
		})
		assert.is_same("table", type(dummy))
		assert.is_same("foo", dummy.foo)
		assert.is_same(1, dummy.bar)
		assert.is_same(true, dummy.baz)
	end)

	it("Should create different instances", function()
		local dummy1 = Dummy({
			foo = "foo",
			bar = 1,
			baz = true,
		})
		local dummy2 = Dummy({
			foo = "foo",
			bar = 1,
			baz = true,
		})
		assert.is_same(dummy1, dummy2)
		assert.is_not_equal(dummy1, dummy2)
	end)

	it("should throw error if initialization values are not correct", function()
		assert.has_error(function()
			Dummy({
				foo = "foo",
				bar = "not a number",
				baz = "not a boolean",
			})
		end, "bar is not of type number; baz is not of type boolean")
	end)
end)
