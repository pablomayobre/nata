local ochre = {}

local World = setmetatable({}, {
	__index = function(self, k)
		return rawget(self, k) or function(self, ...)
			self:callAll(k, ...)
		end
	end
})

function World:add(entity, ...)
	self:call(entity, 'onAdd', ...)
	table.insert(self._entities, entity)
	return entity
end

function World:get(f)
	if f then
		local entities = {}
		for _, entity in pairs(self._entities) do
			if f(entity) then
				table.insert(entities, entity)
			end
		end
		return entities
	else
		return self._entities
	end
end

function World:call(entity, event, ...)
	if self.systems[event] then
		for i = 1, #self.systems[event] do
			self.systems[event][i](self, entity, ...)
		end
	end
end

function World:callAll(event, ...)
	for _, entity in pairs(self._entities) do
		self:call(entity, event, ...)
	end
end

function World:remove(f)
	f = f or function() return true end
	for i = #self._entities, 1, -1 do
		if f(self._entities[i]) then
			self:call(self._entities[i], 'onRemove')
			self:onRemove(self._entities[i])
			table.remove(self._entities, i)
		end
	end
end

function ochre.new()
	return setmetatable({
		systems = {},
		_entities = {},
	}, {
		__index = World,
	})
end

return ochre