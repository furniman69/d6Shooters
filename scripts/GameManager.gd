extends Node

signal player_moved(new_position_index)

var rations = 6
var ammunition = 6
var gold = 3
var members = 12
var days = 0
var position = 0  # Posición en el mapa
var max_position = 0 # Se inicializará desde el JSON

# Objetos especiales
var has_compass = false
var has_hunter = false
var has_prospector_map = false
var has_binoculars = false
var has_medicine = false
var weapon_upgrade = 0

func _ready():
    # Cargar la longitud del tablero desde el JSON
    var file = FileAccess.open("res://assets/data/board_data.json", FileAccess.READ)
    if file:
        var content = file.get_as_text()
        var board_data = JSON.parse_string(content)
        file.close()
        if board_data != null and board_data.has("paths") and board_data["paths"][0].has("length"):
            max_position = board_data["paths"][0]["length"] - 1 # El índice es 0-based
        else:
            print("ERROR: No se pudo cargar la longitud del tablero desde board_data.json")
    else:
        print("ERROR: No se pudo abrir board_data.json")

func move_player(spaces):
    position += spaces
    print("Movido " + str(spaces) + " espacios. Posición actual: " + str(position))
    emit_signal("player_moved", position)
    
    # Verificar si llegó a Reno
    if position >= max_position:
        win_game()
    
    # Verificar eventos en el camino
    check_for_events()

func check_for_events():
    # Lógica simplificada para eventos aleatorios
    if randi() % 10 == 0:  # 10% de probabilidad de evento
        handle_random_event()

func handle_random_event():
    var event_roll = randi() % 6 + 1
    match event_roll:
        1:
            print("Evento: Atajo - Avanzas 3 espacios")
            move_player(3)
        2:
            print("Evento: Rebaño - Puedes cambiar 1 Munición por 2 Raciones")
            if ammunition > 0:
                ammunition -= 1
                rations += 2
        3:
            print("Evento: Vagón de tren - Comercio disponible")
        4:
            print("Evento: Camino despejado - No ocurre nada")
        5:
            print("Evento: Perdidos - Pierdes 1 día y 1 ración")
            days += 1
            rations = max(0, rations - 1)
        6:
            print("Evento: Aviso - Pierdes 1 miembro o 1 oro y 1 ración")
            if gold > 0 and rations > 0:
                gold -= 1
                rations -= 1
            else:
                members = max(0, members - 1)

func handle_extreme_heat():
    print("¡Calor Extremo!")
    # Lógica para el calor extremo
    var heat_roll = randi() % 6 + 1
    if heat_roll >= 3:
        if rations > 0:
            rations -= 1
            print("Perdiste 1 ración por el calor extremo")
        else:
            members = max(0, members - 1)
            print("Perdiste 1 miembro por el calor extremo")

func handle_griggs_attack():
    print("¡La banda de Griggs ataca!")
    # Lógica simplificada para el ataque
    var attack_roll = randi() % 6 + 1
    if attack_roll >= 3:
        members = max(0, members - 1)
        print("Perdiste 1 miembro en el ataque")

func advance_day():
    days += 1
    print("Día " + str(days))
    
    # Verificar límite de tiempo
    if days >= 40:
        lose_game("Se acabó el tiempo. No llegaste a Reno en 40 días.")
    
    # Lógica para el reparto de raciones cada 5 días
    if days % 5 == 0:
        distribute_rations()

func distribute_rations():
    print("Día de reparto de raciones")
    if rations < members:
        # Lógica para perder miembros si no hay suficientes raciones
        var members_lost = members - rations
        members -= members_lost
        rations = 0
        print("Se perdieron " + str(members_lost) + " miembros por falta de raciones.")
        if members <= 0:
            lose_game("Derrota: Todos los miembros del grupo han muerto de hambre.")
    else:
        rations -= members
        print("Raciones distribuidas. Quedan " + str(rations) + " raciones.")

func win_game():
    var score = calculate_score()
    print("¡Victoria! Llegaste a Reno en " + str(days) + " días.")
    print("Puntuación final: " + str(score))
    # Aquí se mostraría una pantalla de victoria

func lose_game(message):
    print(message)
    # Aquí se mostraría una pantalla de derrota

func calculate_score():
    var score = 10  # Por llegar a Reno
    score += (40 - days) * 5  # Por cada día antes del límite
    score += members * 3  # Por cada miembro vivo
    score += gold * 2  # Por cada oro
    score += rations  # Por cada ración
    score += (ammunition / 2)  # Por cada 2 municiones
    return score

func buy_item(item_name, cost):
    if gold >= cost:
        gold -= cost
        match item_name:
            "rations":
                rations += 2
            "ammunition":
                ammunition += 2
            "member":
                members += 1
        return true
    return false

