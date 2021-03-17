local Object = {}

-- Define a getter that caches the result for the next time it is called
-- This is a static method (self = the class); in this class system static methods start with __ by convention
function Object:__cache_getter(name, func)
	-- cache key: prevent overriding the getter function itself
	local key = "_" .. name
	-- add a function to the class
	self[name] = function(self)
		-- check if the value is present in the cache
		local value = self[key]

		-- `== nil` instead of `not value` to allow caching boolean values
		if value == nil then
			-- call the getter function
			value = func(self)
		end

		-- store result in cache
		self[key] = value

		-- return result
		return value
	end
end

-- Define a getter / setter
-- If no argument is specified, it will act as a getter, else as a setter
-- The specified function MUST return the new value, if it returns nil, nil will be used as new value
-- Optionally works in combination with a previously defined cache getter and only really makes sense in that context
function Object:__setter(name, func)
	-- since the function is overridden, we need to store the old one in case a cache getter is defined
	local cache_getter = self[name]
	-- use same key as cache getter to modify getter cache if present
	local key = "_" .. name

	self[name] = function(self, new)
		-- check whether an argument was specified
		if new == nil then
			if cache_getter then
				-- call the cache getter if present
				return cache_getter(self)
			else
				-- return the value else
				return self[key]
			end
		end

		-- call the setter and set the new value to the result
		self[key] = func(self, new)
	end
end

-- Define a comparator function
-- Acts like a setter, except that it does not set the new value but rather compares the present and specified values and returns whether they are equal or not
-- Incompatible with setter
-- The function is optional. The == operator is used else.
function Object:__comparator(name, func)
	local cache_getter = self[name]
	local key = "_" .. name

	self[name] = function(self, expected)
		-- the current value is needed everytime, no matter whether there is an argument or not
		local actual

		if cache_getter then
			-- call the cache getter if present
			actual = cache_getter(self)
		else
			-- use the value else
			actual = self[key]
		end

		-- act as a getter if there is no argument
		if expected == nil then
			return actual
		end

		if func then
			-- if a function as specified, call it
			return func(actual, expected)
		else
			-- else, use the == operator to compare the expected value to the actual
			return actual == expected
		end
	end
end

-- Override an already existing function in a way that the old function is called
-- If nil is returned, the old function is called. Else the return value is returned. (Only the first return value is taken into concern here, multiple are supported tho)
-- This works even if it is applied to the instance of a class when the function is defined by the class
-- It also works with overriding functions that are located in superclasses
function Object:__override(name, func)
	-- store the old function
	local old_func = self[name]

	-- redefine the function with variable arguments
	self[name] = function(...)
		-- call the new function and store the return values in a table
		local rvals = {func(...)}
		-- if nil was returned, fall back to the old function
		if rvals[1] == nil then
			-- if present, call the return function with the values the new function returned (converted back to a tuple)
			return old_func(...)
		else
			-- return the values from the new function else
			return unpack(rvals)
		end
	end
end

-- Works like override except that the new function does not modify the output of the old function but rather the input
-- The new function can decide with what arguments by returing them, including the `self` reference
-- If the "self" arg is not returned the old function is not called
-- Note that this way the new function cannot change the return value of the old function
function Object:__pipe(name, func)
	local old_func = self[name]

	self[name] = function(self, ...)
		local rvals = {func(self, ...)}
		-- check if self was returned properly
		if rvals[1] then
			-- if present, call the return function with the values the new function returned (converted back to a tuple)
			return old_func(unpack(rvals))
		end
	end
end

-- Make class available as table to distribute the Object table
class = setmetatable({Object = Object}, {
	-- Create a new class by calling class() with an optional superclass argument
	__call = function(super)
		return setmetatable({}, {
			-- Create a new instance of the class when the class is called
			__call = function(_class, ...)
				-- Check whether the first argument is an instance of the class
				-- If that is the case, just return it - this is to allow "making sure something is the instance of a class" by calling the constructor
				local argtbl = {...}
				local first_arg = args[1]
				if first_arg and type(first_arg) == "table" and inst.CLASS = _class then
					return inst
				end
				-- set the metatable and remember which class the object belongs to
				local instance = setmetatable({CLASS = _class}, {
					__index = _class,
				})
				-- call the constructor if present
				if instance.constructor then
					instance:constructor(...)
				end
				-- return the created instance
				return instance
			end,
			-- Object as superclass of all classes that dont have a different one
			__index = super or Object,
		})
	end
}

