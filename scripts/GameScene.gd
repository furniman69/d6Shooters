extends Control

@onready var game_manager = GameManager
@onready var dice_manager = DiceManager
@onready var game_board = %GameBoard
@onready var player_node = %GameBoard/Player

@onready var rations_label = $UI/ResourcePanel/RationsLabel
@onready var ammunition_label = $UI/ResourcePanel/AmmunitionLabel
@onready var gold_label = $UI/ResourcePanel/GoldLabel
@onready var members_label = $UI/ResourcePanel/MembersLabel
@onready var days_label = $UI/ResourcePanel/DaysLabel

@onready var roll_button = $UI/DicePanel/RollButton
@onready var resolve_button = $UI/DicePanel/ResolveButton

func _ready():
	update_ui()
	dice_manager.dice_rolled.connect(on_dice_rolled)
	dice_manager.dice_resolved.connect(on_dice_resolved)
	game_manager.player_moved.connect(on_player_moved)
	
	# Posicionar al jugador en el inicio del tablero
	player_node.position = game_board.get_position_for_index(game_manager.position)

func update_ui():
	rations_label.text = str(game_manager.rations)
	ammunition_label.text = str(game_manager.ammunition)
	gold_label.text = str(game_manager.gold)
	members_label.text = str(game_manager.members)
	days_label.text = "Días: " + str(game_manager.days)

func _on_RollButton_pressed():
	dice_manager.roll_dice()
	roll_button.disabled = true
	resolve_button.disabled = false

func _on_ResolveButton_pressed():
	dice_manager.resolve_dice()
	roll_button.disabled = false
	resolve_button.disabled = true
	game_manager.advance_day()
	update_ui()

func on_dice_rolled(red_dice_values, white_dice_values):
	print("Dados Rojos: ", red_dice_values)
	print("Dados Blancos: ", white_dice_values)
	# Aquí se actualizaría la UI para mostrar los dados tirados

func on_dice_resolved():
	print("Dados resueltos.")
	# Aquí se actualizaría la UI después de resolver los dados

func on_player_moved(new_position_index):
	player_node.position = game_board.get_position_for_index(new_position_index)
