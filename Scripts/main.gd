extends Node

@export var snake_scene : PackedScene

var score: int 
var game_started: bool

var cells : int = 20
var cell_size : int = 50

var old_data : Array
var snake_data : Array
var snake : Array

var start_pos = Vector2(9,9)
var up = Vector2(0 , -1)
var down = Vector2( 0 , 1)
var right = Vector2( 1, 0)
var left = Vector2( -1, 0)
var move_direction : Vector2
var can_move : bool

var food_pos : Vector2
var regen_food : bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0 
	$CanvasLayer.get_node("ScoreLabel").text = "Score:" + str(score)
	move_direction = up
	can_move = true
	generate_snake()
	move_food()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0 , cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
func move_snake():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
	if can_move:
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()
	if can_move:
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()
	if can_move:
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
func start_game():
	game_started = true
	$Timer.start()
				
		

func _on_timer_timeout():
	can_move = true
	
	old_data = [] + snake_data
	snake_data[0] += move_direction
	
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_data[i-1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0 , cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()
func end_game():
	$GameOverMenu.show()
	$Timer.stop()
	game_started = false
	get_tree().paused = true
func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$CanvasLayer.get_node("ScoreLabel").text = "Score:" + str(score)
		add_segment(old_data[-1])
		move_food()
func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0 , cell_size)
	regen_food = true


func _on_game_over_menu_restart():
	new_game()
