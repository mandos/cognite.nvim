local assert = require("luassert")
local Option = require("cognite.functional.option")

describe("Option", function()
	describe("Some", function()
		it("should return a table with a value and is_some = true", function()
			local value = "some value"
			local result = Option.Some(value)
			assert.are.same(true, result.is_some)
			assert.are.same(value, result.value)
		end)
	end)

	describe("None", function()
		it("should return a table with is_some = false", function()
			local result = Option.None()
			assert.are.same(false, result.is_some)
		end)
	end)

	describe("function", function()
		it("should behave as Option Some (return function)", function()
			local value = "some value"
			local result = Option(value)
			assert.are.same(true, result.is_some)
			assert.are.same(value, result.value)
		end)

		-- it("should compose with fmap", function()
		-- 	local compose = require("cognite.func").compose
		-- 	local fmap = require("cognite.func").fmap
		-- 	local optionUpperString = compose(fmap(string.upper), Option)
		-- 	local result = optionUpperString("hi")
		-- 	assert.are.same("Option", result.__type)
		-- 	assert.are.same(true, result.is_some)
		-- 	assert.are.same("HI", result.value)
		-- end)
	end)
end)

describe("map for Option", function()
	-- it("should return lifted function", function()
	-- 	local optionUpperString = Option.map(string.upper)
	-- 	assert.are.same("function", type(optionUpperString))
	-- end)
	it("should obey identity law", function()
		local id = function(x)
			return x
		end
		local result = Option("hi"):map(id)
		assert.are.same("Option", result.__type)
		assert.are.same(true, result.is_some)
		assert.are.same("hi", result.value)
	end)

	it("should obey composition law", function()
		local add42 = function(v)
			return v + 42
		end
		local multiple2 = function(v)
			return v * 2
		end
		local compose1 = Option(0):map(add42):map(multiple2)
		local compose2 = Option(0):map(function(v)
			return multiple2(add42(v))
		end)
		assert.are.same(compose1, compose2)
	end)

	it("should obey homomorphism law", function()
		local add42 = function(v)
			return v + 42
		end
		local result1 = Option(0):map(add42)
		local result2 = Option(add42(0))
		assert.are.same(result1, result2)
	end)
end)

describe("bind for option", function()
	it("should obey left identity law", function()
		local add42 = function(v)
			return Option(v + 42)
		end

		local result1 = Option(0):bind(add42)
		local result2 = add42(0)
		assert.are.same(result1, result2)
	end)

	it("should obey right identity law", function()
		local result1 = Option(42):bind(Option)
		local result2 = Option(42)
		assert.are.same(result1, result2)
	end)

	it("should obey associativity law", function()
		local add42 = function(v)
			return Option(v + 42)
		end
		local multiple2 = function(v)
			return Option(v * 2)
		end

		local result1 = Option(0):bind(add42):bind(multiple2)
		local result2 = Option(0):bind(function(v)
			return add42(v):bind(multiple2)
		end)
		assert.are.same(result1, result2)
	end)
end)
