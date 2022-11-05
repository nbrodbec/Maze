local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maze = {}
Maze.dependencies = {
    modules = {"SeedService"},
    utilities = {"Shuffle"},
    dataStructures = {"DisjointSet"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local WALL_HEIGHT = 50
local WALL_WIDTH = 1

local mazes = {}

---- Public Functions ----

function Maze.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function newMaze(part)
        part.Transparency = 1
        part.CanCollide = true
        local n = part:GetAttribute("n") or 12
        local cellSize = part:GetAttribute("cellSize")
        local edges = Maze.generate(n)
        local id = part:GetAttribute("id")
        Maze.build(edges, cellSize, part.CFrame)

        local startPart = Instance.new("Part")
        startPart.Size = Vector3.new(cellSize, WALL_HEIGHT, WALL_WIDTH)
        startPart.Anchored = true
        startPart.CanCollide = false
        startPart.Transparency = 1
        local finishPart = startPart:Clone()

        startPart.CFrame = part.CFrame * CFrame.new(0, WALL_HEIGHT/2, 0)
        finishPart.CFrame = part.CFrame * CFrame.new(cellSize*(n-0.5) - cellSize/2, WALL_HEIGHT/2, -cellSize*n)
        startPart.Parent, finishPart.Parent = workspace.TriggerParts, workspace.TriggerParts
        startPart.Name, finishPart.Name = "start", "finish"

        local maze = {
            origin = part.CFrame * CFrame.new(-cellSize/2, 0, 0),
            n = n,
            id = id,
            edges = edges,
            cellSize = cellSize,
            startPart = startPart,
            finishPart = finishPart,
            wallModel = ReplicatedStorage.Walls:FindFirstChild(part.Name.."Wall"),
            vertexModel = ReplicatedStorage.Walls:FindFirstChild(part.Name.."Vertex")
        }
        mazes[id] = maze
    end
    CollectionService:GetInstanceAddedSignal("maze_origin"):Connect(newMaze)
    for _, p in CollectionService:GetTagged("maze_origin") do
        newMaze(p)
    end

    Maze.build(Maze.generate(50), 0.52, workspace.PART.CFrame, 0.2, 0.2, {Transparency = 0, Color = Color3.new(1,1,1)})
end

-- Implements Randomized Kruskal's Algorithm
function Maze.generate(n)
    local edges = {}
    local nodes = {}
    for i = 1, n do
        local row = {}
        nodes[i] = row
        for j = 1, n do
            nodes[i][j] = dataStructures.DisjointSet.new()

            if i > 1 then
                table.insert(edges, {{i, j}, {i-1, j}})
            end
            if j > 1 then
                table.insert(edges, {{i, j}, {i, j-1}})
            end
        end
    end

    local walls = {}
    for _, edge in ipairs(utilities.Shuffle(edges, modules.SeedService.getSeed())) do
        local coord1, coord2 = edge[1], edge[2]
        local node1, node2 = nodes[coord1[1]][coord1[2]], nodes[coord2[1]][coord2[2]]
        if node1:find() == node2:find() then
            table.insert(walls, edge)
        else
            node1:union(node2)
        end
    end

    -- Outside walls
    for i = 1, n do
        if i ~= 1 then table.insert(walls, {{i, 1}, {i, 0}}) end
        if i ~= n then table.insert(walls, {{i, n}, {i, n+1}}) end
        table.insert(walls, {{1, i}, {0, i}})
        table.insert(walls, {{n, i}, {n+1, i}})
    end

    return walls
end

function Maze.build(walls, cellSize, origin, mazeHeight, wallWidth, wallProps)
    origin = origin and origin*CFrame.new(-cellSize/2, 0, 0) or CFrame.new()
    local maze = Instance.new("Folder")
    mazeHeight = mazeHeight or WALL_HEIGHT
    wallWidth = wallWidth or WALL_WIDTH

    for _, edge in walls do
        local i1, i2 = edge[1], edge[2]
        local x1, x2 = i1[1]-1, i2[1]-1
        local y1, y2 = i1[2]-1, i2[2]-1
        local node1Cf = origin * CFrame.new(x1*cellSize + cellSize/2, mazeHeight/2, -y1*cellSize - cellSize/2)
        local node2Cf = origin * CFrame.new(x2*cellSize + cellSize/2, mazeHeight/2, -y2*cellSize - cellSize/2)
        local perp = node2Cf.Position - node1Cf.Position

        local cf = CFrame.fromMatrix(node1Cf.Position + perp/2, perp.Unit, origin.UpVector)

        local wall = Instance.new("Part")
        wall.Anchored = true
        wall.CanCollide = false
        wall.CanQuery = true
        wall.Size = Vector3.new(wallWidth, mazeHeight, cellSize+wallWidth)
        wall.Transparency = wallProps and wallProps.Transparency or 1
        wall.Color = wallProps and wallProps.Color or Color3.new()
        wall.CFrame = cf
        wall.Parent = maze
    end

    maze.Parent = workspace.MazeParts
    return maze
end

function Maze.getInfo(id)
    return mazes[id]
end

return Maze