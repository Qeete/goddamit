extends Control

@export var target_position: Vector2
@export var move_duration: float = 0.5
@export var spawn_scale: Vector2 = Vector2(0.5, 0.5)
@export var final_scale: Vector2 = Vector2(1, 1)

# Заполняем визуал студента данными из ресурса
func setup(data: StudentData) -> void:
	if data == null:
		return
	# Меняем фото если в сцене есть TextureRect
	var photo_node = get_node_or_null("TextureRect")
	if photo_node and data.photo:
		photo_node.texture = data.photo

func appear() -> void:
	global_position = Vector2(target_position.x - 200, target_position.y)
	scale = spawn_scale
	modulate.a = 0

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, move_duration / 500)
	tween.tween_property(self, "scale", final_scale, move_duration)
	tween.tween_property(self, "modulate:a", 1, move_duration)

func leave() -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(global_position.x - 200, global_position.y), move_duration)
	tween.tween_property(self, "modulate:a", 0, move_duration)
	tween.connect("finished", Callable(self, "queue_free"))
