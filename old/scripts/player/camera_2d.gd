extends Camera2D

@export var target: Node2D
@export var smooth_speed: float = 8.0  # Увеличил значение для лучшей отзывчивости
@export var look_ahead: float = 10.0  # Предпросмотр вперед

func _ready():
	# Включаем сглаживание ПРАВИЛЬНО
	position_smoothing_enabled = true
	position_smoothing_speed = smooth_speed  # Исправлено: должно быть position_smoothing_speed

func _process(delta):
	if target:
		# Плавное перемещение к цели
		var target_position = target.global_position
		
		# Добавляем предпросмотр в направлении движения
		if target is CharacterBody2D:
			var look_offset = target.velocity.normalized() * look_ahead
			target_position += look_offset
		
		# Обновляем скорость сглаживания на случай изменения в инспекторе
		position_smoothing_speed = smooth_speed
		
		# Используем встроенное сглаживание камеры вместо ручного lerp
		global_position = global_position.lerp(target_position, smooth_speed * delta)
