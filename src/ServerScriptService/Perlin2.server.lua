local MapContainer = workspace.PerlinContainer
local ClientComs = game.ReplicatedStorage.RemoteEvent

local Debounce = true

local gridPart = Instance.new("Part")
gridPart.TopSurface = Enum.SurfaceType.Smooth
gridPart.Name = "GridPart"
gridPart.Anchored = true
gridPart.CanCollide = false
gridPart.Size = Vector3.new(5, 5, 5)

local function rand(n)
	local r = math.random(-n, n)
	if r == 0 then r = 1 end --it breaks if it is 0
	return r
end

--Packet Size is the amount of blocks per packet, Grid Size is how many blocks per map
--Example: generatePlainMap(4, 16) has 4 blocks per 4 subsections of the map, for a total of 16 blocks.
local function generatePlainMap(packetSize, gridSize)
	Debounce = true
	--Clean up section
	for _, part in pairs(MapContainer:GetChildren()) do
		part:Destroy()
	end
	
	--Grid section
	gridSize = math.clamp(gridSize, packetSize, packetSize*100) or packetSize
	if gridSize % packetSize ~= 0 then
		gridSize = gridSize + (gridSize%packetSize)
	end
	gridSize = gridSize -1
	
	--Packet and gridpart generation
	for i=0, gridSize, packetSize do
		wait()
		coroutine.wrap(function()
			for j=0, gridSize, packetSize do
				wait()
				coroutine.wrap(function()
					local fold = Instance.new("Folder")
					fold.Name = "Packet"..(((i)/packetSize)+1)..(((j)/packetSize)+1)
					fold.Parent = MapContainer
					
					local index1 = i
					local index2 = j
					for x=0, (packetSize-1) do
						wait()
						coroutine.wrap(function()
							for z=0, (packetSize-1) do
								local x1 = (index1 * gridPart.Size.X) + (x * gridPart.Size.X) + gridPart.Size.X/2
								local z1 = (index2 * gridPart.Size.Z) + (z * gridPart.Size.Z) + gridPart.Size.Z/2
								wait()
								local c = gridPart:Clone()
								c.Position = Vector3.new(x1, 0, z1)
								c.Parent = fold
							end
						end)()
					end
				end)()
			end
		end)()
	end
	
	--This creates a new file for each position, and allows for accessing by name
	--If I were to reapproach this, I would just make it an internal table for the program
	local vectCont = Instance.new("Folder")
	vectCont.Name = "VectorContainer"
	vectCont.Parent = MapContainer
	
	local vectNum = math.sqrt(#MapContainer:GetChildren())+5
	for x=0, vectNum do
		coroutine.wrap(function()
			for z=0, vectNum do
				local Vect = Instance.new("Folder") --the Vector "object"
				Vect.Name = "Vector"..(x+1)..(z+1)
				Vect.Parent = vectCont
				
				local pp = Vector2.new(rand(999)/999, rand(999)/999).Unit
				local vVectX = Instance.new("NumberValue") --the vector x
				vVectX.Name = "VecX"
				vVectX.Value = math.clamp(pp.X, -1, 1)
				vVectX.Parent = Vect
				local vVectZ = Instance.new("NumberValue") --the vector Z
				vVectZ.Name = "VecZ"
				vVectZ.Value = math.clamp(pp.Y, -1, 1)
				vVectZ.Parent = Vect
				local PosInfo = Instance.new("Vector3Value") --the positional vector
				PosInfo.Name = "Position"
				local x1 = x * gridPart.Size.X * packetSize
				local z1 = z * gridPart.Size.Z * packetSize 
				PosInfo.Value = Vector3.new(x1, 0, z1)
				PosInfo.Parent = Vect
			end
		end)()
	end
end

local function generateMapOutOfPlain()
	local partContainers = {}
	
	for _, fold in pairs(MapContainer:GetChildren()) do
		if fold.Name ~= "VectorContainer" then
			table.insert(partContainers, fold)
		end
	end
	
	for _, partFolder in pairs(partContainers) do --for every part folder in the container
		wait()
		local CenterX = string.sub(partFolder.Name, #partFolder.Name-1, #partFolder.Name-1)
		local CenterZ = string.sub(partFolder.Name, #partFolder.Name, #partFolder.Name)
		local vecTable = {
			MapContainer.VectorContainer["Vector"..CenterX..CenterZ],
			MapContainer.VectorContainer["Vector"..(CenterX+1)..CenterZ],
			MapContainer.VectorContainer["Vector"..CenterX..(CenterZ+1)],
			MapContainer.VectorContainer["Vector"..(CenterX+1)..(CenterZ+1)],
		}
		coroutine.wrap(function()
			for _, part in pairs(partFolder:GetChildren()) do --for every part in the part folder
				wait()
				local v2Pos = Vector2.new(part.Position.X, part.Position.Z) --why do i translate every thing to 2 dimension? idk
				
				--Calculations upon Calculations upon Calculations
				local GradVects = { --god this is a lot
					Vector2.new(vecTable[1].VecX.Value, vecTable[1].VecZ.Value).Unit,
					Vector2.new(vecTable[2].VecX.Value, vecTable[2].VecZ.Value).Unit,
					Vector2.new(vecTable[3].VecX.Value, vecTable[3].VecZ.Value).Unit,
					Vector2.new(vecTable[4].VecX.Value, vecTable[4].VecZ.Value).Unit,
				}
				
				local cStones = { --corner stones or points...
					Vector2.new(vecTable[1].Position.Value.X, vecTable[1].Position.Value.Z),
					Vector2.new(vecTable[2].Position.Value.X, vecTable[2].Position.Value.Z),
					Vector2.new(vecTable[3].Position.Value.X, vecTable[3].Position.Value.Z),
					Vector2.new(vecTable[4].Position.Value.X, vecTable[4].Position.Value.Z),
				}
				
				local dVectors = {
					(v2Pos - cStones[1]).Unit,
					(v2Pos - cStones[2]).Unit,
					(v2Pos - cStones[3]).Unit,
					(v2Pos - cStones[4]).Unit,
				}
				local dots = {
					dVectors[1]:Dot(GradVects[1]),
					dVectors[2]:Dot(GradVects[2]),
					dVectors[3]:Dot(GradVects[3]),
					dVectors[4]:Dot(GradVects[4]),
				}
				
				--The Fancy Equation
				local ab = dots[1] + ((v2Pos.X - cStones[1].X)/(cStones[1] - cStones[2]).Magnitude)*(dots[2] - dots[1])
				local cd = dots[3] + ((v2Pos.X - cStones[3].X)/(cStones[3] - cStones[4]).Magnitude)*(dots[4] - dots[3])
				local finVal = ab + ((v2Pos.Y - cStones[1].Y)/(cStones[1] - cStones[3]).Magnitude)*(cd - ab)
				--print((v2Pos.X - cStones[1].X)/(cStones[2].X - cStones[1].X))
				--print("AB: "..ab..", CD: "..cd..", Final: "..finVal)
				
				part.Position = Vector3.new(v2Pos.X, finVal * gridPart.Size.Y * 0.875, v2Pos.Y)
				
				local redC = (finVal+1)/2 --Rises with the FinVal (Direct)
				local greenC = -((finVal+1)/2)*(((finVal+1)/2)+1) --Parabola that rises at 0.5 (which comes out to 1) when finVal == 0
				local blueC = 1-((finVal+1)/2) --Falls with the FinVal (Inverse)
				if finVal < -0.35 or finVal > 0.9 then
					greenC = 0
				end
				part.Color = Color3.new(redC, greenC, blueC)
			end
		end)()
	end
	Debounce = false
end

math.randomseed(tick() + time()) --second step
wait(1.25)
generatePlainMap(9, 72)
wait(1.5) --Dramatic Effect
generateMapOutOfPlain()

Debounce = false --Used to avoid generating while it is already generating

--If the user wishes to regenerate a new map
ClientComs.OnServerEvent:Connect(function(player, message)
	math.randomseed(tick() + time()) --second step
	if message == "MakeNew" and not Debounce then
		generatePlainMap(9, 72)
		wait(1.5) --Dramatic Effect
		generateMapOutOfPlain()
	end
end)
