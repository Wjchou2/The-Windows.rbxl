local ModelVibrate = {}

-- Vibrates/shakes a model by rapidly offsetting its pivot in random directions.
-- model:   The Model to shake (must have a PrimaryPart set)
-- duration:  How long the shake lasts in seconds (default 0.5)
-- intensity: Maximum offset in studs per axis per frame (default 0.3)
-- frequency: How many shakes per second (default 30)
function ModelVibrate.vibrate(model, duration, intensity, frequency)
	if not model or not model:IsA("Model") then
		warn("ModelVibrate: expected a Model, got", typeof(model))
		return
	end

	if not model.PrimaryPart then
		warn("ModelVibrate: model must have a PrimaryPart set")
		return
	end

	duration  = duration  or 0.5
	intensity = intensity or 0.3
	frequency = frequency or 30

	local originalCFrame = model:GetPivot()
	local interval = 1 / frequency
	local elapsed = 0

	task.spawn(function()
		while elapsed < duration do
			-- Ramp intensity down over time for a natural decay
			local t = elapsed / duration
			local currentIntensity = intensity * (1 - t)

			local offsetX = (math.random() * 2 - 1) * currentIntensity
			local offsetY = 0
			local offsetZ = (math.random() * 2 - 1) * currentIntensity

			local offset = Vector3.new(offsetX, offsetY, offsetZ)
			model:PivotTo(originalCFrame + offset)

			task.wait(interval)
			elapsed = elapsed + interval
		end

		-- Snap back to original position
		model:PivotTo(originalCFrame)
	end)
end

return ModelVibrate