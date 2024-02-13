extends Label


func _ready():
	visible_characters = 0


func scroll(wait):
	for i in text.length():
		visible_characters += 1
		await get_tree().create_timer(wait).timeout
