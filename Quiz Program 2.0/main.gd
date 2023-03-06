extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	ExternalFlags.clear_flag("currently_quizzing")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ExternalFlags.flag_is_set("currently_quizzing"):
		$CardViewer.visible = false
