extends CanvasLayer

func set_health(value: int, max_value: int):
	$HealthBar.max_value = max_value
	$HealthBar.value = value

	var ratio = float(value) / float(max_value)
	var color = Color(0,1,0)
	if ratio <= 0.6: color = Color(1,1,0)
	if ratio <= 0.3: color = Color(1,0,0)

	# Works for ProgressBar
	$HealthBar.add_theme_color_override("fg_color", color)
