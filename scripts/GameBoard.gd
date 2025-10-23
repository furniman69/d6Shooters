extends Node2D

var board_data = {}
var path_nodes_visual = [] # Almacenará los nodos visuales de las casillas
var cell_size = Vector2(50, 50) # Tamaño de cada casilla visual
var cell_spacing = 10 # Espacio entre casillas

func _ready():
	load_board_data()
	generate_visual_path_nodes()

func load_board_data():
	var file = FileAccess.open("res://assets/data/board_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		board_data = JSON.parse_string(content)
		file.close()
		if board_data == null:
			print("ERROR: Failed to parse board_data.json")
	else:
		print("ERROR: Could not open board_data.json")

func generate_visual_path_nodes():
	path_nodes_visual.clear()
	if board_data.has("paths"):
		var main_path_data = board_data["paths"][0] # El primer path es el principal
		var current_pos = Vector2(100, 100) # Posición inicial en el pergamino
		var cells_per_segment = 10 # Número de casillas antes de un posible cambio de dirección
		var segment_count = 0
		var direction = Vector2(1, 0) # Dirección inicial (derecha)

		for i in range(main_path_data["length"]):
			var cell_node = Control.new()
			cell_node.name = "Cell_" + str(i)
			cell_node.custom_minimum_size = cell_size
			cell_node.position = current_pos
			add_child(cell_node)
			path_nodes_visual.append(cell_node)

			# Añadir un color de fondo para visualizar la casilla
			var rect = ColorRect.new()
			rect.color = Color(0.8, 0.8, 0.8, 0.5) # Gris claro semitransparente
			rect.size = cell_size
			cell_node.add_child(rect)

			# Añadir texto para el índice de la casilla (opcional, para depuración)
			var label = Label.new()
			label.text = str(i)
			label.add_theme_font_size_override("font_size", 10)
			label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			cell_node.add_child(label)

			# Lógica para cambiar de dirección y crear una ruta más orgánica
			if segment_count >= cells_per_segment:
				# Cambiar dirección aleatoriamente o en un patrón
				var rand_dir = randi() % 4
				if rand_dir == 0: direction = Vector2(1, 0) # Derecha
				elif rand_dir == 1: direction = Vector2(0, 1) # Abajo
				elif rand_dir == 2: direction = Vector2(-1, 0) # Izquierda
				elif rand_dir == 3: direction = Vector2(0, -1) # Arriba
				segment_count = 0

			current_pos += direction * (cell_size.x + cell_spacing)
			segment_count += 1

			# Asegurarse de que las casillas no se salgan del pergamino (ajuste aproximado)
			# Estas coordenadas son relativas al nodo GameBoard (el pergamino)
			current_pos.x = clamp(current_pos.x, 50, 750)
			current_pos.y = clamp(current_pos.y, 50, 550)

		# Marcar ciudades y eventos en el camino principal
		for town in main_path_data["towns"]:
			if town["index"] < path_nodes_visual.size():
				var town_label = Label.new()
				town_label.text = town["name"]
				town_label.add_theme_font_size_override("font_size", 14)
				town_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
				path_nodes_visual[town["index"]].add_child(town_label)

		for event_index in main_path_data["events"]:
			if event_index < path_nodes_visual.size():
				var event_label = Label.new()
				event_label.text = "E"
				event_label.add_theme_font_size_override("font_size", 16)
				event_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0)) # Rojo
				event_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
				path_nodes_visual[event_index].add_child(event_label)

		# Implementar las bifurcaciones (simplificado visualmente)
		for branch_data in board_data["paths"]:
			if branch_data["type"] == "branch":
				var attach_index = branch_data["attach_to"]["index"]
				var rejoin_index = branch_data["rejoin_to"]["index"]

				if attach_index < path_nodes_visual.size() and rejoin_index < path_nodes_visual.size():
					var attach_pos = path_nodes_visual[attach_index].position
					var rejoin_pos = path_nodes_visual[rejoin_index].position

					# Crear nodos visuales para la rama
					var branch_start_pos = attach_pos + Vector2(cell_size.x + cell_spacing, 0) # Ejemplo de inicio de rama
					var branch_current_pos = branch_start_pos

					for i in range(branch_data["length"]):
						var branch_cell_node = Control.new()
						branch_cell_node.name = "Branch_" + branch_data["id"] + "_Cell_" + str(i)
						branch_cell_node.custom_minimum_size = cell_size
						branch_cell_node.position = branch_current_pos
						add_child(branch_cell_node)

						var rect = ColorRect.new()
						rect.color = Color(0.0, 0.0, 0.8, 0.5) # Azul semitransparente para ramas
						rect.size = cell_size
						branch_cell_node.add_child(rect)

						var label = Label.new()
						label.text = branch_data["id"] + "_" + str(i)
						label.add_theme_font_size_override("font_size", 8)
						label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
						branch_cell_node.add_child(label)

						# Lógica simple para la forma de la rama
						if i < branch_data["length"] / 2:
							branch_current_pos.y += cell_size.y + cell_spacing
						else:
							branch_current_pos.x += cell_size.x + cell_spacing

					# Nota: La conexión visual entre la rama y el camino principal
					# requeriría dibujar líneas o usar Path2D, lo cual es más complejo
					# y se recomienda hacer en el editor de Godot.

func get_position_for_index(index):
	if index >= 0 and index < path_nodes_visual.size():
		# Devolvemos la posición global del nodo visual de la casilla
		return path_nodes_visual[index].global_position
	return Vector2.ZERO

func get_path_length():
	if board_data.has("paths") and board_data["paths"][0].has("length"):
		return board_data["paths"][0]["length"]
	return 0
