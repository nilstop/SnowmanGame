extends Camera2D 
class_name Camera

signal done

var shake_tense: float
var current_shake_ID := 0

func _process(_delta: float) -> void:
	shake_tense = lerp(shake_tense, 0.0, 0.1)

func screen_shake(intensity, multiplier: Vector2 = Vector2(1.0,1.0)):
	current_shake_ID += 1
	var shake_ID = current_shake_ID
	shake_tense = intensity
	# Shake until shake_tense reaches zero
	position_smoothing_enabled = false
	while shake_tense != 0.0:
		var tween = create_tween()
		tween.tween_property(self, "offset", Vector2(randf_range(-shake_tense, shake_tense) * multiplier.x, randf_range(-shake_tense, shake_tense) * multiplier.y), 0.03).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		if shake_ID != current_shake_ID:
			break
	position_smoothing_enabled = true
	emit_signal("done")
