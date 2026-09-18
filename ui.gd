extends CanvasLayer

@onready var player = $"../Player"
@onready var score_label = $Score
@onready var meter_fill = $AimMeter
@onready var meter_bg = $AimMeterBG

var original_meter_width = 0.0

func _ready():
	original_meter_width = meter_fill.size.x
	meter_fill.size.x = 0
	meter_bg.visible = false

	if player:
		player.score_updated.connect(_on_score_updated)
		player.aim_meter_updated.connect(_on_meter_updated)


func _on_score_updated(new_score):
	score_label.text = "SCORE: " + str(new_score)

func _on_meter_updated(ratio):
	if ratio > 0:
		meter_bg.visible = true
		meter_fill.size.x = original_meter_width * ratio
		if ratio < 0.3:
			meter_fill.color = Color(1, 0, 0)
		else:
			meter_fill.color = Color(0, 1, 1) 
	else:
		meter_bg.visible = false
		meter_fill.size.x = 0
