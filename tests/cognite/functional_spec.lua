local assert = require("luassert")
local spy = require("luassert.spy")
local f = require("cognite.functional")
local compose, partial, fmap = f.compose, f.partial, f.fmap

local add20 = function(v)
	return v + 20
end

local add100 = function(v)
	return v + 100
end

local multiple2 = function(v)
	return v * 2
end

describe("compose", function()
	it("should throw exceptions if even one argument is not function", function()
		assert.has_error(compose("not function"))
	end)

	it("should not call function during composition", function()
		local add10Called = false
		local add10 = function(v)
			add10Called = true
			return v + 10
		end
		local add200Called = false
		local add200 = function(v)
			add200Called = true
			return v + 200
		end
		local addMany = compose(add10, add200)
		assert.are_same(false, add10Called)
		assert.are_same(false, add200Called)
		assert.are_same(210, addMany(0))
		assert.are_same(true, add10Called)
		assert.are_same(true, add200Called)
	end)

	it("should return a function", function()
		local result = compose(add20, add100)
		assert.are.same("function", type(result))
	end)

	it("should return a function that return correct value", function()
		local compose1 = compose(multiple2, add100)
		assert.are.same(200, compose1(0))
		local compose2 = compose(add100, multiple2)
		assert.are.same(100, compose2(0))
	end)

	it("should follow associativity rule", function()
		local compose1 = compose(add20, compose(add100, multiple2))
		local compose2 = compose(compose(add20, add100), multiple2)
		assert.are.same(compose1(0), compose2(0))
		local compose3 = compose(add20, add100, multiple2)
		assert.are.same(compose1(0), compose3(0))
	end)
end)

describe("partial", function()
	local add = function(a, b, c)
		return a + b + c
	end

	it("should return a function", function()
		local result = partial(add, 10)
		assert.are.same("function", type(result))
	end)

	it("should return a partial function for one parameter", function()
		local partialAdd = partial(add, 10)
		assert.are_same(60, partialAdd(20, 30))
	end)

	it("should return a partial function for two parameters", function()
		local partialAdd = partial(add, 10, 20)
		assert.are_same(60, partialAdd(30))
	end)
end)

-- describe("fmap", function()
-- 	it("with only first parameter it should return a partial function", function()
-- 		local partialStringUpper = fmap(string.upper)
-- 		assert.are.same("function", type(partialStringUpper))
-- 	end)

-- 	it("should obey identity law", function()
-- 		local id = function(x)
-- 			return x
-- 		end
-- 		local result = fmap(id, option("hi"))
-- 		assert.are.same("Option", result.__type)
-- 		assert.are.same(true, result.is_some)
-- 		assert.are.same("hi", result.value)
-- 	end)

-- 	it("should obey composition law", function()
-- 		local compose1 = compose(fmap(add20), fmap(add100))
-- 		local compose2 = fmap(compose(add20, add100))
-- 		assert.are.same(compose1(option(0)), compose2(option(0)))
-- 	end)

-- describe("with second parameter", function()
-- 	it("as Option.some it should return correct Option.some", function()
-- 		local result = fmap(string.upper, option("hi"))
-- 		assert.are.same("Option", result.__type)
-- 		assert.are.same("HI", result.value)
-- 	end)

-- 	it("as Option.none it should return correct Option.none", function()
-- 		local result = fmap(string.upper, option.none())
-- 		assert.are.same("Option", result.__type)
-- 		assert.are.same(false, result.is_some)
-- 	end)
-- end)
-- end)
