extends Node
class_name RunEconomy

signal coins_changed(coins: int)

var coins: int = 0


func add_coins(amount: int) -> void:
	if amount <= 0:
		return

	coins += amount
	coins_changed.emit(coins)


func can_afford(cost: int) -> bool:
	return cost >= 0 and coins >= cost


func try_spend(cost: int) -> bool:
	if cost < 0 or not can_afford(cost):
		return false

	coins -= cost
	coins_changed.emit(coins)
	return true


func reset() -> void:
	coins = 0
	coins_changed.emit(coins)
