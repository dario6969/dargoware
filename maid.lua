local Maid = {}
Maid.__index = Maid

local function doTask(job)
	local _type = typeof(job)
	if _type == 'function' then
		return job()
	elseif _type == 'RBXScriptConnection' then
		if job.Connected then
			job:Disconnect()
			print('disconnected')
		end
	elseif typeof(job.Destroy) == 'function' then
		job:Destroy()
	end
end

function Maid.new()
	return setmetatable({}, Maid)
end

function Maid.__newindex(self, key, value)
	if self[key] then
		return;
	end

	local oldTask = self[key]
	if oldTask == value then
		return;
	end

	rawset(self, key, value)

	if oldTask then
		doTask(oldTask)
	end
end

function Maid:GiveTask(task)
	if not task then return end

	local taskId = #self + 1
	self[taskId] = task

	return taskId
end

function Maid.delayed(time, job)
	task.delay(time, function()
		doTask(job)
	end)
end

function Maid:DoCleaning()
	for index, job in next, self do
		self[index] = nil
		doTask(job)
	end

	table.clear(self)
end

Maid.Destroy = Maid.DoCleaning

return Maid
