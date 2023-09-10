local assert = require("luassert")
local Array = require("cognite.functional.array")
local fmap = require("cognite.functional").fmap

describe("Array", function()
	it("it should be initialized as function with a table", function()
		local array1 = Array({ 1, 2, 3 })
		assert.are.same("Array", array1.__type)
		assert.are.same({ 1, 2, 3 }, array1)

		local array2 = Array.new({ 1, 2, 3 })
		assert.are.same(array1, array2)
		assert.are_not.equal(array1, array2)
		-- TODO: is it problem?
		-- assert.are.equal(array1.new, array2.new)
	end)

	it("it should be initialized with 'new' contructor and a table", function()
		local array1 = Array.new({ 1, 2, 3 })
		local array2 = Array.new({ 1, 2, 3 })
		assert.are.same(array1, array2)
		assert.are_not.equal(array1, array2)
	end)

	it("should be able to fmap functions", function()
		local array = Array({ 1, 2, 3 })
		local result = array:map(function(v)
			return v + 10
		end)
		assert.are.same({ 11, 12, 13 }, result)
	end)
end)
