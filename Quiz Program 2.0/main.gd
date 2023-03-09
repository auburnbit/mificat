extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
		#must do this or window can't be transparent
	get_tree().get_root().set_transparent_background(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
