--!strict
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--
local lib = script.lib
--
local ConnectionMeta = require(lib.ConnectionMeta)

local Types = require(script.Types)

export type InfoNormal = Types.InfoNormal
export type InfoPosition = Types.InfoPosition
--
local folderKeyCode = Instance.new("Folder", ReplicatedStorage)
folderKeyCode.Name = "KeyCode"

local module = {}

---Use this if button not use delta or position
---@param buttons nil {Enum.KeyCode}
---@param state nil | {Enum.UserInputState}
---@param funct nil | (data: Types.Info) -> () | { ["1"]: (data: Types.Info, ...any?) -> (), ["2"]: any }
---@param createButton nil  boolean?
---@return any
function module.newNormal(
	buttons: { Enum.KeyCode },
	state: nil | { Enum.UserInputState },
	funct: nil | Types.functData | { Types.functData & any },
	createButton: boolean?
): string
	state = if state == nil then { Enum.UserInputState.Begin } else state
	createButton = if createButton == nil then false else createButton

	local id = HttpService:GenerateGUID()

	local function ButtonFunction(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): ()
		if actionName ~= id or not table.find(state :: { Enum.UserInputState }, inputState) then
			return
		end

		local data = { KeyCode = inputObject.KeyCode, InputObject = inputObject, InputState = inputState }
		if type(funct) == "table" then
			local f, t = table.unpack(funct)
			--unpack t
			if type(t) == "table" then
				f(data, table.unpack(t))
			else
				f(data, t)
			end
		elseif type(funct) == "function" then
			funct(data)
		end
	end

	ContextActionService:BindAction(id, ButtonFunction, createButton, table.unpack(buttons))
	return id
end

---Use this if button use delta or position
---@param buttons Enum.KeyCode{}
---@param state nil | {Enum.UserInputState}
---@param funct any
---@return any
function module.newPosition(
	buttons: { Enum.KeyCode },
	state: nil | { Enum.UserInputState },
	funct: nil | Types.functVector
): string
	state = if state == nil then { Enum.UserInputState.Begin } else state

	local id = HttpService:GenerateGUID()

	local folderId
	local PostitionVector, DeltaVector
	do
		folderId = Instance.new("Folder", folderKeyCode)
		folderId.Name = id
		PostitionVector = Instance.new("Vector3Value", folderId)
		PostitionVector.Name = "Position"
		DeltaVector = Instance.new("Vector3Value", folderId)
		DeltaVector.Name = "Delta"
	end

	local function ButtonFunction(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): ()
		if actionName ~= id or not table.find(state :: { Enum.UserInputState }, inputState) then
			return
		end

		local p = inputObject.Position
		local d = inputObject.Delta

		local vc3 = { Position = Vector3.new(p.X, p.Y, 0), Delta = d }

		PostitionVector.Value = vc3.Position
		DeltaVector.Value = vc3.Delta

		if type(funct) ~= "nil" then
			funct(vc3)
		end
	end

	ContextActionService:BindAction(id, ButtonFunction, false, table.unpack(buttons))
	return id
end

---@param id string
function module.UnbindAction(id: string): ()
	ContextActionService:UnbindAction(id)

	if folderKeyCode:FindFirstChild(id) then
		folderKeyCode:FindFirstChild(id):Destroy()
	end
end

ConnectionMeta.AddDisconnect("ControlID", nil, function(v)
	module.UnbindAction(v)
end)

return module
