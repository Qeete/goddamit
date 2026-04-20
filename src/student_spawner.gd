extends Control

# Одна универсальная сцена студента вместо массива сцен
@export var student_scene: PackedScene
# Массив ресурсов — каждый .tres файл это один студент со своими данными
@export var students: Array[StudentData]
@export var spawn_position: Vector2
@export var move_duration: float = 0.5

var current_student_data: StudentData = null
var current_student: Control = null
var _deck: Array[StudentData] = []  # колода студентов

func _ready() -> void:
	randomize()
	_reset_deck()

# Спавн следующего студента из колоды
func spawn_student() -> void:
	if _deck.is_empty():
		_reset_deck()

	# Берём случайного студента из колоды без повторов
	var idx: int = randi() % _deck.size()
	current_student_data = _deck[idx]
	_deck.remove_at(idx)

	# Убираем предыдущего студента если есть
	if current_student != null:
		current_student.leave()
		current_student = null

	if student_scene == null:
		push_error("StudentSpawner: student_scene не назначена!")
		return

	# Создаём студента и передаём ему данные
	var student = student_scene.instantiate()
	get_tree().get_current_scene().add_child(student)
	student.target_position = spawn_position
	student.move_duration = move_duration
	student.setup(current_student_data)  # ← передаём данные в визуал
	student.appear()
	current_student = student

# Студент уходит (документ брошен в его зону)
func remove_current_student() -> void:
	if current_student:
		current_student.leave()
		current_student = null

func _reset_deck() -> void:
	_deck = students.duplicate()
