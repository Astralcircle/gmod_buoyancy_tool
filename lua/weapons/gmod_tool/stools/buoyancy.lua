TOOL.Category = "Constraints"
TOOL.Name = "Buoyancy"
TOOL.Information = {
	{name = "left"},
	{name = "right"}
}

TOOL.ClientConVar["ratio"] = "0"

local function SetBuoyancy(ply, ent, data)
	local phys = ent:GetPhysicsObject()

	if phys:IsValid() then
		local ratio = math.Clamp(data.Ratio or 100, -1000, 1000) / 100
		ent.BuoyancyRatio = ratio
		phys:SetBuoyancyRatio(ratio)
		phys:Wake()

		duplicator.StoreEntityModifier(ent, "buoyancy", data)
	end
end

if SERVER then
	duplicator.RegisterEntityModifier("buoyancy", SetBuoyancy)
	
	local function RestoreBuoyancy(ply, ent)
		local ratio = ent.BuoyancyRatio

		if ratio then
			local phys = ent:GetPhysicsObject()

			if phys:IsValid() then
				timer.Simple(0 , function()
					if phys:IsValid() then
						phys:SetBuoyancyRatio(ratio)
					end
				end)
			end
		end
	end

	hook.Add("PhysgunDrop", "BuoyancyTool", RestoreBuoyancy)
	hook.Add("GravGunOnDropped", "BuoyancyTool", RestoreBuoyancy)
else
	language.Add("tool.buoyancy.name", "Buoyancy Tool")
	language.Add("tool.buoyancy.desc", "Change the buoyancy of an object")
	language.Add("tool.buoyancy.left", "Apply buoyancy")
	language.Add("tool.buoyancy.right", "Copy buoyancy")
end

function TOOL:LeftClick(trace)
	local ent = trace.Entity
	if not ent:IsValid() then return end
	if CLIENT then return true end

	SetBuoyancy(self:GetOwner(), ent, {Ratio = self:GetClientNumber("ratio")})

	return true
end

function TOOL:RightClick(trace)
	local ent = trace.Entity
	if not ent:IsValid() then return end
	if CLIENT then return true end

	local phys = ent:GetPhysicsObject()
	self:GetOwner():ConCommand("buoyancy_ratio " .. (phys:IsValid() and (ent.BuoyancyRatio or phys:GetBuoyancyRatio()) * 100))

	return true
end

local default_convars = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
	panel:ToolPresets("buoyancy", default_convars)
	panel:NumSlider("Percent", "buoyancy_ratio", 0, 100)
	panel:ControlHelp("Buoyancy percent, where 0% is not buoyant at all (like a rock), and 100% is very buoyant (like wood). You can set values larger than 100% for greater effect.")
end
