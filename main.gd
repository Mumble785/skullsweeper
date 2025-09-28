extends Node

# array representation of game board, initialized blank.
# 0-8 are used to represent hint values, 9 represents a skull.
var grid_rep = [
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0]
]
var clicker_count := 0


# for use when calculating hint values
func dynamic_clamp(y, x):
	if grid_rep[y][x] < 8:
		grid_rep[y][x] += 1


func _ready():
	# set locations of skulls + impossible skullfinder mech guard
	var i = 0
	while i in range(7):
		var row = randi_range(0,6)
		var col = randi_range(0,6)
		
		# impossible puzzle guard, irrelevant until mech incorporated
		#var impossible = false
		#if grid_rep[row].count(9) >= 6:
		#	impossible = true
		#while impossible == true:
		#	row = randi_range(0,6)
		#	impossible = false
		#	if grid_rep[row].count(9) >= 6:
		#		impossible = true
		
		# must be 7 skulls total cuz i said so
		if grid_rep[row][col] == 9:
			continue
		else:
			grid_rep[row][col] = 9
			i += 1
	
	# calculate hints (exhausted wheezing)
	for y in range(7):
		for x in range(7):
			if grid_rep[y][x] == 9:
				var top_row	= true if y == 0 else false
				var bottom_row = true if y == 6 else false
				var left_edge = true if x == 0 else false
				var right_edge = true if x == 6 else false
				
				if not top_row and not left_edge:
					dynamic_clamp(y-1,x-1)
				if not top_row and not right_edge:
					dynamic_clamp(y-1,x+1)
				if not bottom_row and not left_edge:
					dynamic_clamp(y+1,x-1)
				if not bottom_row and not right_edge:
					dynamic_clamp(y+1,x+1)
				if not left_edge:
					dynamic_clamp(y,x-1)
				if not right_edge:
					dynamic_clamp(y,x+1)
				if not top_row:
					dynamic_clamp(y-1,x)
				if not bottom_row:
					dynamic_clamp(y+1,x)
	
	# assign grid data to game board
	for cell in $Board.get_children():
		cell.set_value(grid_rep[cell.cell_id.y][cell.cell_id.x])


func game_over():
	$GameOver.visible = true


func _on_cell_clicked(is_skull, hint_val, coord):
	# auto-click adjacent empty cells
	if hint_val == 0:
		var all_cells = $Board.get_children()
		for cell in all_cells:
			if cell.cell_id.x >= coord.x-1 and cell.cell_id.x <= coord.x+1:
				if cell.cell_id.y >= coord.y-1 and cell.cell_id.y <= coord.y+1:
					var counts = cell.auto_click()
					clicker_count += 1 if counts else 0
	elif not is_skull:
		clicker_count += 1
	
	# lose condition
	if is_skull:
		$GameOver.text = "GAME OVER"
		game_over()
		# expose all skulls
		var all_cells = $Board.get_children()
		for cell in all_cells:
			cell.skulls_win()
		
	# win condition
	if clicker_count == 42:
		$GameOver.text = "YOU LIVED >:("
		game_over()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
