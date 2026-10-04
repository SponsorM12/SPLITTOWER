extends CharacterBody2D

# Настройки движения
@export var speed : float = 200.0
@export var sprint_multiplier : float = 1.5
@export var dash_speed : float = 600.0
@export var dash_duration : float = 0.15
@export var dash_cooldown : float = 0.3
@export var attack_impulse : float = 100.0
@export var parry_duration : float = 0.2

# Состояния персонажа
enum STATE {NORMAL, DASHING, ATTACKING, PARRYING}
var current_state = STATE.NORMAL

# Таймеры и переменные
var dash_timer : float = 0.0
var cooldown_timer : float = 0.0
var parry_timer : float = 0.0
var attack_timer : float = 0.0
var dash_direction : Vector2 = Vector2.ZERO
var attack_direction : Vector2 = Vector2.ZERO

# Сигналы для анимаций
signal state_changed(new_state)
signal dash_started(direction)
signal attack_started(direction)
signal parry_started()

func _ready():
	# Инициализация
	pass

func _physics_process(delta):
	# Обновление таймеров
	update_timers(delta)
	
	# Обработка ввода в зависимости от состояния
	match current_state:
		STATE.NORMAL:
			handle_normal_state(delta)
		STATE.DASHING:
			handle_dash_state(delta)
		STATE.ATTACKING:
			handle_attack_state(delta)
		STATE.PARRYING:
			handle_parry_state(delta)
	
	move_and_slide()

func update_timers(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if current_state == STATE.DASHING:
		dash_timer -= delta
		if dash_timer <= 0:
			set_state(STATE.NORMAL)
	
	if current_state == STATE.PARRYING:
		parry_timer -= delta
		if parry_timer <= 0:
			set_state(STATE.NORMAL)
	
	if current_state == STATE.ATTACKING:
		attack_timer -= delta
		if attack_timer <= 0:
			set_state(STATE.NORMAL)

func handle_normal_state(_delta):
	var direction = get_input_direction()
	
	# Бег
	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	# Рывок или парирование
	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0:
		if direction != Vector2.ZERO:
			start_dash(direction)
		else:
			start_parry()
		return
	
	# Атака
	if Input.is_action_just_pressed("attack"):
		start_attack()
		return
	
	# Обычное движение
	velocity = direction.normalized() * current_speed

func handle_dash_state(_delta):
	# Во время рывка можно начать атаку
	if Input.is_action_just_pressed("attack"):
		start_attack()
		return
	
	# Движение в направлении рывка
	velocity = dash_direction * dash_speed

func handle_attack_state(_delta):
	# Во время атаки нельзя менять действие
	# Легкий импульс в направлении атаки
	velocity = attack_direction * attack_impulse

func handle_parry_state(_delta):
	# Во время парирования персонаж замирает
	velocity = Vector2.ZERO

func get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	return direction

func get_mouse_direction() -> Vector2:
	# Альтернативный способ через viewport
	var mouse_pos = get_viewport().get_mouse_position()
	var _player_screen_pos = get_viewport().get_camera_2d().global_position if get_viewport().get_camera_2d() else Vector2.ZERO
	var direction = (mouse_pos - get_viewport().size * 0.5)  # Относительно центра экрана
	
	return direction.normalized()

func start_dash(direction: Vector2):
	set_state(STATE.DASHING)
	dash_direction = direction.normalized()
	dash_timer = dash_duration
	cooldown_timer = dash_cooldown
	dash_started.emit(dash_direction)

func start_parry():
	set_state(STATE.PARRYING)
	parry_timer = parry_duration
	cooldown_timer = dash_cooldown
	velocity = Vector2.ZERO
	parry_started.emit()

func start_attack():
	set_state(STATE.ATTACKING)
	attack_direction = get_mouse_direction()
	attack_timer = 0.2  # Длительность атаки
	cooldown_timer = 0.2
	velocity = attack_direction * attack_impulse
	attack_started.emit(attack_direction)

func set_state(new_state):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)

# Внешние вызовы для анимаций и эффектов
func is_busy() -> bool:
	return current_state != STATE.NORMAL

func can_parry() -> bool:
	return current_state == STATE.PARRYING

func get_current_state() -> int:
	return current_state
