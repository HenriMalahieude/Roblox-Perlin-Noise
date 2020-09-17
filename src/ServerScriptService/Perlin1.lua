local pCont = workspace.PerlinContainer
local coms = game.ReplicatedStorage.RemoteEvent

local deb = true

local gridPart = Instance.new("Part")
gridPart.TopSurface = Enum.SurfaceType.Smooth
gridPart.Name = "GridPart"
gridPart.Anchored = true
gridPart.CanCollide = false
gridPart.Size = Vector3.new(5, 5, 5)

local function generateGrid(gridSize) --generates the grid :T
	--clean up section
	for _, p in pairs(pCont:GetChildren()) do
		p:Destroy()
	end
	
	wait()
	
	gridSize = math.clamp(gridSize, 5, 99) or 5
	gridSize = gridSize - 1
	for x=0, gridSize do
		wait()
		coroutine.wrap(function()
			local tX = x
			for y=0, gridSize do
				local nPar = gridPart:Clone()
				nPar.Position = Vector3.new(tX * gridPart.Size.X + gridPart.Size.X, 0, y * gridPart.Size.Z + gridPart.Size.Z)
				nPar.Parent = pCont
			end
		end)()
	end
end

local function perl(gridSize)
	deb = true
	generateGrid(gridSize)
	
	wait(0.5)
	local function rand(n)
		return math.random(-n, n)
	end
	local GradVects = { --yup, its a doozy
		Vector2.new(rand(500)/500, rand(500)/500).Unit,
		Vector2.new(rand(500)/500, rand(500)/500).Unit,
		Vector2.new(rand(500)/500, rand(500)/500).Unit,
		Vector2.new(rand(500)/500, rand(500)/500).Unit,
	}
	
	local cStones = { --corner stones or points...
		Vector2.new(0,0),
		Vector2.new(gridSize*gridPart.Size.X + gridPart.Size.X, 0),
		Vector2.new(0, gridSize*gridPart.Size.Z + gridPart.Size.Z),
		Vector2.new(gridSize*gridPart.Size.X + gridPart.Size.X, gridSize*gridPart.Size.Z + gridPart.Size.Z)
		}
	
	for _, p in pairs(pCont:GetChildren()) do
		wait()
		if p:IsA("Part") then
			local v2Pos = Vector2.new(p.Position.X, p.Position.Z)
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
			local ab = dots[1] + (v2Pos.X/(cStones[1] - cStones[2]).Magnitude)*(dots[2] - dots[1])
			local cd = dots[3] + (v2Pos.X/(cStones[3] - cStones[4]).Magnitude)*(dots[4] - dots[3])
			local finVal = ab + (v2Pos.Y/(cStones[1] - cStones[3]).Magnitude)*(cd - ab)
			p.Position = Vector3.new(v2Pos.X, finVal * gridPart.Size.Y * 1.75, v2Pos.Y)
			p.Color = Color3.new((finVal+1)/2, -((finVal+1)/2)*(((finVal+1)/2)+1), 1-((finVal+1)/2))
			--print(finVal)
		end
	end
	deb = false
end

--math.randomseed(tick() + time()) --second step
--wait(3)
--perl(9)

--coms.OnServerEvent:Connect(function(plr, mess)
--	math.randomseed(tick() + time()) --second step
--	if mess == "MakeNew" and not deb then
--		perl(9)
--	end
--end)