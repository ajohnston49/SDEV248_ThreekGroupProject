extends Control

func show_peace(text: String):
	$Panel/PeaceLabel.text = text
	$Panel/PeaceLabel.visible = true
	$Panel/WarLabel.visible = false
	visible = true

func show_war(text: String):
	$Panel/WarLabel.text = text
	$Panel/WarLabel.visible = true
	$Panel/PeaceLabel.visible = false
	visible = true

func hide_dialog():
	$Panel/PeaceLabel.visible = false
	$Panel/WarLabel.visible = false
	visible = false
