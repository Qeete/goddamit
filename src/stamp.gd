extends Area2D

@export var stamp_type: String = "approved"  # "approved" или "denied"
@export var stamp_mark_scene: PackedScene
# Укажи путь к StudentSpawner в инспекторе
@export var student_spawner_path: NodePath

var is_held: bool = false
var original_position: Vector2
var _spawner: Node = null

func _ready() -> void:
	original_position = global_position
	if student_spawner_path:
		_spawner = get_node(student_spawner_path)

func _process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()

	if Input.is_action_just_pressed("mouse_left"):
		if not is_held and _is_mouse_over():
			is_held = true
			return
		if is_held:
			_place_stamp()

	if Input.is_action_just_pressed("mouse_right"):
		if is_held:
			_release_stamp()

func _is_mouse_over() -> bool:
	var shape = $CollisionShape2D.shape
	var rect = Rect2(global_position - shape.size / 2, shape.size)
	return rect.has_point(get_global_mouse_position())

func _place_stamp() -> void:
	var mouse_pos = get_global_mouse_position()

	for doc in get_tree().get_nodes_in_group("documents"):
		var rect = doc.get_global_rect()
		if rect.has_point(mouse_pos):
			# Ставим отпечаток на документ
			if stamp_mark_scene:
				var mark = stamp_mark_scene.instantiate()
				mark.position = doc.get_local_mouse_position()
				# Передаём тип штампа если у mark есть такой метод
				if mark.has_method("set_stamp_type"):
					mark.set_stamp_type(stamp_type)
				doc.add_child(mark)

			# Возвращаем штамп на место
			_release_stamp()

			# Ждём чуть и отправляем студента в нужную сторону
			_react_to_stamp()
			return

func _react_to_stamp() -> void:
	if _spawner == null:
		return
	# Небольшая задержка — чтобы игрок увидел штамп на документе
	await get_tree().create_timer(0.8).timeout
	if stamp_type == "approved":
		_spawner.approve_current_student()
	else:
		_spawner.deny_current_student()

func _release_stamp() -> void:
	is_held = false
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, 0.2)
