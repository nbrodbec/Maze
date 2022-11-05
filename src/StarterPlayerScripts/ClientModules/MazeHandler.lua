local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MazeHandler = {}
MazeHandler.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {"Queue"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local player = Players.LocalPlayer

local mazes = {}

---- Private Functions ----

local function makeModel(cell1, cell2, maze)
    local wallHeight = maze.wallModel.PrimaryPart.Size.Y
    local x1, x2 = cell1[1]-1, cell2[1]-1
    local y1, y2 = cell1[2]-1, cell2[2]-1
    local node1Cf = maze.origin * CFrame.new(
        x1*maze.cellSize + maze.cellSize/2,
        wallHeight/2,
        -y1*maze.cellSize - maze.cellSize/2
    )
    local node2Cf = maze.origin * CFrame.new(
        x2*maze.cellSize + maze.cellSize/2,
        wallHeight/2,
        -y2*maze.cellSize - maze.cellSize/2
    )

    local perp = node2Cf.Position - node1Cf.Position
    local cf = CFrame.fromMatrix(node1Cf.Position + perp/2, perp.Unit, Vector3.new(0, 1, 0))

    local wall = maze.wallModel:Clone()
    wall:SetPrimaryPartCFrame(cf)
    return wall
end

local function fillCell(maze, coord, walls, vertices)
    task.spawn(function()
        local x, y = coord.X, coord.Y
        local sides = {
            Vector3.new(x-0.5, y, 0),
            Vector3.new(x+0.5, y, 0),
            Vector3.new(x, y-0.5, 0),
            Vector3.new(x, y+0.5, 0)
        }
        local corners = {
            Vector3.new(x-0.5, y-0.5, 0),
            Vector3.new(x+0.5, y+0.5, 0),
            Vector3.new(x+0.5, y-0.5, 0),
            Vector3.new(x-0.5, y+0.5, 0)
        }
        for _, side in sides do
            if maze.walls[side] then
                maze.walls[side].Parent = workspace
                walls[maze.walls[side]] = true
            end
        end
        for _, corner in corners do
            if maze.vertices[corner] then
                maze.vertices[corner].Parent = workspace
                vertices[maze.vertices[corner]] = true
            end
        end
    end)
end

---- Public Functions ----

function MazeHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    RunService.Heartbeat:Connect(function(dt)
        local character = player.Character
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            local position = character.HumanoidRootPart.Position
            for _, maze in mazes do
                local relativePos = maze.origin:PointToObjectSpace(position)
                relativePos = Vector3.new(relativePos.X, -relativePos.Z, 0)
                if relativePos.X < 1 or relativePos.Y < 1 then
                    relativePos = Vector3.new(1, 1, 0)
                elseif relativePos.X > maze.n*maze.cellSize or relativePos.Y > maze.n*maze.cellSize then
                    relativePos = Vector3.new(maze.n*maze.cellSize, maze.n*maze.cellSize, 0)
                end
                local x = math.ceil(relativePos.X / maze.cellSize)
                local y = math.ceil(relativePos.Y / maze.cellSize)
                if maze.playerPos ~= Vector3.new(x, y, 0) then
                    maze.playerPos = Vector3.new(x, y, 0)
                    maze:update()
                end
            end
        end
    end)
end

function MazeHandler.new(mazeInfo)
    local maze = setmetatable({
        origin = mazeInfo.origin,
        cellSize = mazeInfo.cellSize,
        n = mazeInfo.n,
        id = mazeInfo.id,
        wallModel = mazeInfo.wallModel,
        vertexModel = mazeInfo.vertexModel,
        walls = {},
        vertices = {},
        cache = {},
        playerPos = Vector3.new(1, 1, 0)
    }, {__index = MazeHandler})

    for _, edgeTable in mazeInfo.edges do
        local cell1, cell2 = edgeTable[1], edgeTable[2]
        local wall = makeModel(cell1, cell2, maze)
        local edge = Vector3.new(
            (cell1[1] + cell2[1])/2,
            (cell1[2] + cell2[2])/2,
            0
        )

        maze.walls[edge] = wall
    end

    for i = 0, maze.n do
        for j = 0, maze.n do
            local cf = maze.origin * CFrame.new(i*maze.cellSize, maze.vertexModel.PrimaryPart.Size.Y/2, -j*maze.cellSize)
            local vertex = maze.vertexModel:Clone()
            vertex:SetPrimaryPartCFrame(cf)
            maze.vertices[Vector3.new(i+0.5, j+0.5, 0)] = vertex
        end
    end

    task.spawn(function()
        maze:update()
    end)
    mazes[maze.id] = maze

    return maze
end

function MazeHandler:update()
    if not self.cache[self.playerPos] then
        local directions = {
            Vector3.new(-1, 0, 0),
            Vector3.new(0, 1, 0),
            Vector3.new(1, 0, 0),
            Vector3.new(0, -1, 0)
        }
    
        local walls = {}
        local vertices = {}
        local visited = {
            [Vector3.new(1, 0, 0)] = true,
            [Vector3.new(self.n, self.n+1, 0)] = true
        }
    
        local primaryQueue = dataStructures.Queue.new()
        primaryQueue:enqueue(self.playerPos)
        primaryQueue:enqueue(0)
    
        while not primaryQueue:isEmpty() do
            local cell = primaryQueue:dequeue()
            local depth = primaryQueue:dequeue()
            if depth > 3 or visited[cell] then continue end
    
            fillCell(self, cell, walls, vertices)
            visited[cell] = true
            for _, direction in ipairs(directions) do
                local queue = dataStructures.Queue.new()
                if not self.walls[cell + direction/2] then
                    queue:enqueue(cell + direction)
                end
                
                while not queue:isEmpty() do
                    local currCell = queue:dequeue()
                    if visited[currCell] then continue end
                    fillCell(self, currCell, walls, vertices)
                    visited[currCell] = true
    
                    if not self.walls[currCell + direction/2] then
                        queue:enqueue(currCell + direction)
                    end
                    for _, d in directions do
                        if not self.walls[currCell + d/2] then
                            primaryQueue:enqueue(currCell + d)
                            primaryQueue:enqueue(depth+1)
                        end
                    end
                end
            end
        end
        for _, wall in pairs(self.walls) do 
            if not walls[wall] then 
                wall.Parent = nil 
            end 
        end
        for _, vertex in pairs(self.vertices) do 
            if not vertices[vertex] then 
                vertex.Parent = nil 
            end 
        end
        self.cache[self.playerPos] = {
            walls = walls, 
            vertices = vertices
        }
    else
        local walls = self.cache[self.playerPos].walls
        local vertices = self.cache[self.playerPos].vertices
        for _, wall in pairs(self.walls) do 
            if walls[wall] then 
                wall.Parent = workspace 
            else
                wall.Parent = nil
            end 
        end
        for _, vertex in pairs(self.vertices) do 
            if vertices[vertex] then 
                vertex.Parent = workspace 
            else
                vertex.Parent = nil
            end 
        end
    end
end

function MazeHandler:calculatePath()
    local start = self.playerPos
    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 1, 0),
        Vector3.new(0, -1, 0)
    }
    local visited = {
        [Vector3.new(1, 0, 0)] = true
    }
    local path = {}

    local function visit(pos)
        if visited[pos] then return false end
        if pos == Vector3.new(self.n, self.n+1, 0) then return true end
        visited[pos] = true

        local include = false
        for _, dir in directions do
            if not self.walls[pos + dir/2] then
                include = include or visit(pos + dir)
            end
        end
        if include then
            table.insert(path, pos)
        end
        return include
    end
    visit(start)
    return path
end

function MazeHandler:destroy()
    mazes[self.id] = nil
    for _, wall in self.walls do wall:Destroy() end
    for _, vertex in self.vertices do vertex:Destroy() end
end

return MazeHandler