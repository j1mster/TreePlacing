-- # Services #--

local Workspace 			= game:GetService("Workspace")
local Selection 			= game:GetService("Selection")



-- # Local Functions #--

local function cleanupParts(Model : Model)
	if Model.PrimaryPart then Model.PrimaryPart:Destroy() end

	for _, v in Model:GetChildren() do 
		if v:IsA("BasePart") and v.Transparency==1 then 
			v:Destroy() 
		end 
	end

	return Model
end

local function weldModel(Model : Model)
	if not Model.PrimaryPart then return end 

	Model.PrimaryPart.Anchored = true

	for _, Part in Model:GetDescendants() do 
		if Part:IsA("BasePart") and not (Part == Model.PrimaryPart) then
			local Weld = Instance.new("Weld", Model.PrimaryPart)
			Weld.C0 = Model.PrimaryPart.CFrame:ToObjectSpace(Part.CFrame) 
			Weld.C1 = CFrame.new(0,0,0)
			Weld.Part0 = Model.PrimaryPart
			Weld.Part1 = Part
			Weld.Name = `{Part.Name}Weld`
			Part.Anchored = false
		end
	end

	return Model
end

local function createPrimaryPart(Model : Model) 
	cleanupParts(Model)

	local ModelCFrame, ModelSize 	= Model:GetBoundingBox() 
	local ModelPosition 			= ModelCFrame.Position
	local LowestPoint 				= ModelPosition.Y - (ModelSize.Y / 2)  


	local PrimaryPart = Instance.new("Part", Model)

	do 
		PrimaryPart.Name = "PrimaryPart"
		PrimaryPart.Size = Vector3.new(1, 1, 1)
		PrimaryPart.Anchored = true
		PrimaryPart.CanCollide = false
		PrimaryPart.Transparency = 0.5 
		PrimaryPart.BrickColor = BrickColor.Red()
		PrimaryPart.Position = Vector3.new(ModelPosition.X, LowestPoint, ModelPosition.Z)
	end

	Model.PrimaryPart = PrimaryPart

	return weldModel(Model)
end


local function sortTrees(Starter)
	local Options = {}
	for _, StartTree in Starter do 
		local NewTree = StartTree:Clone()

		createPrimaryPart(NewTree)

		table.insert(Options, NewTree)
	end 

	return Options
end

local function getY(Model : Model, Position, HighestY) 
	if not Model.PrimaryPart then return false end 

	local RaycastParams = RaycastParams.new()
	RaycastParams.FilterDescendantsInstances = {Model}
	RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	RaycastParams.IgnoreWater = false 

	local RayResult = Workspace:Raycast(Position, (Vector3.new(0, -1, 0) * math.abs(Position.Y-HighestY)), RaycastParams) 

	if RayResult and RayResult.Material then 
		if RayResult.Material.Name=="Grass" or RayResult.Material.Name=="LeafyGrass" or RayResult.Material.Name=="Ground" then 
			return RayResult.Position.Y 
		end
	end

	return false
end


-- # Functions #--

function SpawnTrees(Trees, TreeCount, Start, End, SpecifiedFolder, SilenceWarnings)
	local StartTime = tick()

	local Folder = SpecifiedFolder or Instance.new("Folder")
	local Trees = sortTrees((Trees or Selection:Get()))

	local WorldTop = End.Y or 100 
	local WorldBottom = Start.Y or -500  

	local Failed = {}
	local Successes = {}


	if WorldTop < WorldBottom then 
		if not SilenceWarnings then 
			error("Start Y must be the bottom of the world, End Y must be the top.")
		end 
		return 
	end 


	for i=1, (TreeCount or #Trees) do
		local LocalStart = tick()
		local Tree = Trees[math.random(1, #Trees)]:Clone()


		if Tree:IsA("BasePart") then 
			local TreeModel = Instance.new("Model")
			TreeModel.Name = Tree.Name
			Tree.Parent = TreeModel
			Tree = TreeModel
		end

		if not Tree.PrimaryPart then 
			Failed[i] = "Primary Part not found"
			Tree:Destroy()
			continue 
		end

		local t = 50
		local PositionX, PositionY, PositionZ = nil, nil, nil
		repeat 
			t = t - 1
			PositionX, PositionY, PositionZ = math.random(Start.X, End.X), getY(Tree, Vector3.new(PositionX, WorldTop, PositionZ), WorldBottom), math.random(Start.Z, End.Z)
		until PositionY or t==0

		if not PositionY then 
			Failed[i] = "Unable to create Y"
			Tree:Destroy()
			continue 
		end

		Tree:PivotTo(CFrame.new(Vector3.new(PositionX, PositionY, PositionZ)) * CFrame.Angles(0, math.rad(math.random(0, 180)), 0))
		Tree.Parent = Folder

		local LocalEnd = tick()

		Successes[i] = {Tree, (LocalEnd-LocalStart)}
	end

	local EndTime = tick()

	if not SilenceWarnings then 
		local Time = EndTime - StartTime
		local Average = Time / TreeCount
		local Fails = Failed
		local Successes = (function() -- Because of the specified index (which is done for debugging) you cant just do #Successes
			local c = 0 
			for _ in Successes do 
				c = c + 1
			end
			return c
		end)()
		local Failed = (function() -- Because of the specified index (which is done for debugging) you cant just do #Failed
			local c = 0 
			for _ in Failed do 
				c = c + 1
			end
			return c 
		end)()

		warn(`Created {Successes} ({Failed} failed) trees\n\tTime elapsed: {Time}s.\n\tAverage Time/Tree: {Average}`)
		warn(Fails)
	end

	Folder.Parent = (SpecifiedFolder and SpecifiedFolder.Parent) or (Workspace) 
end



-- # Finalized #--

return SpawnTrees








--[[ #  Example Usage:

- In references to the "world", the "world" is the region of where the trees are supposed to be placed.

- Anything without a "(+)" after the title is REQUIRED. Things WITH a "(+)" after the title are optional.

- Params must be in order. If you would like to leave one as the default, leave that param in the order as "nil"



Parameters: 

	Param1: ** Tree references **  	(+)
		- Set to nil to use your studio selection (if using this in studio)
		
		
	Param2: ** Tree Count ** 		(+)
		- Amount of trees you would like to spawn. 
		
		- If set to nil, will just use the amount of trees given 
		
		
	Param3: ** Start Position ** 
		- Starting position of the world. Must be less than the end position in all values. Y must be the 
			bottom the possible tree positions (cutoff point). 
			
		- Required for the algorithm to work properly. 
		
		
	Param4: ** End Position ** 
		- Ending position of the world. Must be more than the start position in all values: INCLUDING Y. 
			Y must be the top of the possible tree positions. 
			
		- Required for the algorithm to work properly. 
		
		
	Param5: ** Folder ** 			(+)
		- Folder for all trees to go into.
		
		- If set to nil, will create a new folder in the workspace.
	
			
	Param6: ** Silence Warnings ** 	(+)
		- Using in a game? No worries! Add "true" as a 6th param to silence the script :) 
		
		- Luau errors will not be silenced. Call under a `pcall` to silence Luau errors.

		




Examples - Tree module is the instance of this script as a modulescript: 

	require(treemodule)(nil, 50, Vector3.new(-1024, -8, -1024), Vector3.new(1024, 16, 1024))
	
	pcall(require(treemodule), nil, 50, Vector3.new(-1024, -8, -1024), Vector3.new(1024, 16, 1024))

]]
