extends Node

signal dice_rolled(red_dice, white_dice)
signal dice_resolved()

var red_dice = [0, 0, 0]
var white_dice = [0, 0, 0, 0, 0]
var locked_red = [false, false, false]
var locked_white = [false, false, false, false, false]
var roll_count = 0

func _ready():
    pass

func roll_dice():
    roll_count += 1
    
    # Tirar dados no bloqueados
    for i in range(3):
        if not locked_red[i]:
            red_dice[i] = randi() % 6 + 1
    
    for i in range(5):
        if not locked_white[i]:
            white_dice[i] = randi() % 6 + 1
    
    # Bloquear automáticamente los 5 y 6 en dados rojos en la primera tirada
    if roll_count == 1:
        for i in range(3):
            if red_dice[i] == 5 or red_dice[i] == 6:
                locked_red[i] = true
    
    # Si es la tercera tirada, bloquear todos los dados
    if roll_count == 3:
        for i in range(3):
            locked_red[i] = true
        for i in range(5):
            locked_white[i] = true
    
    emit_signal("dice_rolled", red_dice, white_dice)

func lock_die(is_red, index):
    if is_red:
        # No se pueden desbloquear dados rojos con 5 o 6 en la primera tirada si ya están bloqueados
        if roll_count == 1 and (red_dice[index] == 5 or red_dice[index] == 6):
            return
        locked_red[index] = true
    else:
        locked_white[index] = true

func unlock_die(is_red, index):
    # No se pueden desbloquear dados rojos con 5 o 6 en la primera tirada
    if is_red and roll_count == 1 and (red_dice[index] == 5 or red_dice[index] == 6):
        return
    
    if is_red:
        locked_red[index] = false
    else:
        locked_white[index] = false

func resolve_dice():
    # Resolver dados en orden numérico (1, 2, 3, 4, 5, 6)
    var all_dice = []
    
    # Agregar dados rojos
    for i in range(3):
        all_dice.append({"value": red_dice[i], "is_red": true, "index": i})
    
    # Agregar dados blancos
    for i in range(5):
        all_dice.append({"value": white_dice[i], "is_red": false, "index": i})
    
    # Ordenar por valor
    all_dice.sort_custom(func(a, b): return a.value < b.value)
    
    # Resolver cada dado
    for die in all_dice:
        resolve_single_die(die.value, die.is_red)
    
    # Reiniciar para el siguiente turno
    reset_dice()
    emit_signal("dice_resolved")

func resolve_single_die(value, is_red):
    # Esta función se completará en los siguientes pasos
    pass

func reset_dice():
    roll_count = 0
    for i in range(3):
        locked_red[i] = false
        red_dice[i] = 0
    for i in range(5):
        locked_white[i] = false
        white_dice[i] = 0


