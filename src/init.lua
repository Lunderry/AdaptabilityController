--!nonstrict
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--
local Module = ReplicatedStorage.Module
local SubModule = Module.SubModule
--
local ConnectionMeta = require(SubModule.ConnectionMeta)
--
local plr = Players.LocalPlayer or Players.PlayerAdded:Wait()
--
local folderKeyCode = plr:WaitForChild("FolderKeyCode")
--
local MIN_INPUT = 0.05
local countID = 1

local module = {}

---@param func any | "" | {any | {}}
---@param buttons Enum.KeyCode{}
---@param state Enum.UserInputState{}?
---@param createButton boolean?
---@return any
function module.newBind(
	func: any | "" | { any | {} },
	buttons: { { Enum.KeyCode | Vector2 } } | { Enum.KeyCode },
	state: { Enum.UserInputState }?,
	createButton: boolean?
): number
	local _state = if state == nil then { Enum.UserInputState.Begin } else state :: { Enum.UserInputState }
	local _createButton = if createButton == nil then false else createButton

	local id = tostring(countID)

	local param = {}

	for i, v in buttons :: { any } do
		if type(v) == "table" then
			param[v[1]] = v[2]
			v[i] = v[1] :: Enum.KeyCode

			local value = Instance.new("Vector3Value", folderKeyCode)
			value.Name = id
		end
	end

	local function newfunct(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): ()
		if actionName ~= id or not table.find(_state, inputState) then
			return
		end

		if param[inputObject.KeyCode] then
			local p = inputObject.Position
			p = Vector3.new(math.abs(p.X) < MIN_INPUT or p.X, math.abs(p.Y) < MIN_INPUT or p.Y, 0)
			folderKeyCode[id].Value = p
		elseif type(func) == "function" then
			func()
		elseif type(func) == "table" then
			local tb = func :: { any | {} }
			tb[1](if type(tb[2]) == "table" then table.unpack(tb[2]) else tb[2])
		end
	end

	ContextActionService:BindAction(tostring(countID), newfunct, _createButton, table.unpack(buttons))

	countID += 1
	return id
end

---@param id string
function module.UnbindAction(id: string): ()
	ContextActionService:UnbindAction(id)
end

--Create meta ControlID
ConnectionMeta.AddDisconnect("ControlID", {
	__mewindex = function(self, i, v)
		rawset(self, i, v)
		warn(self, i, v)
	end,
}, function(v)
	module.UnbindAction(v)
end)

return module
