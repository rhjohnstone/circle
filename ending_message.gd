extends MarginContainer

func _ready():
	$PanelContainer.visible = false


func scroll():
	var container = $PanelContainer/VSplitContainer
	await container.get_node("Message1").scroll(0.1)
	await get_tree().create_timer(1).timeout
	await container.get_node("Message2").scroll(0.1)
	await get_tree().create_timer(1).timeout
	await container.get_node("Message3").scroll(0.1)
	await get_tree().create_timer(2).timeout
	await container.get_node("Message4").scroll(0.2)
