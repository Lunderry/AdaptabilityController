export type InfoNormal = {
	KeyCode: Enum.KeyCode,
	InputObject: InputObject,
	InputState: Enum.UserInputState,
}

export type InfoPosition = {
	Position: Vector3,
	Delta: Vector3,
}
export type functData = (data: InfoNormal, ...any?) -> ()

export type functVector = (vct3: InfoPosition, ...any) -> ()

return nil
