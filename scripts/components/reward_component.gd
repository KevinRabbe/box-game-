extends Node
class_name RewardComponent

@export var coins: int = 1


func get_coin_reward() -> int:
	return maxi(0, coins)
