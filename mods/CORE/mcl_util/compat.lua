if not core.handle_async then
	core.handle_async = function(func, callback, ...)
		callback(func(...))
	end
end
