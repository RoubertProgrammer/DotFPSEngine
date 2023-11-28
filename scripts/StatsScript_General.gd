extends Control

@onready var healthtxt:RichTextLabel = $HealthPanel/HealthTxt
@onready var ammotxt:RichTextLabel = $AmmoPanel/AmmoTxt

func _process(delta):
	if not GameStats.is_alive:
		$HealthPanel.visible = false
		$AmmoPanel.visible = false
	$DeathPanel.visible = !GameStats.is_alive
	healthtxt.text = str(GameStats.health)
	ammotxt.text = str(GameStats.ammo) + " | " + str(GameStats.glock)
	pass
