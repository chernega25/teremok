extends Panel

func _ready():
	pass

func _process(_delta):
	if !$TypingTimer.is_stopped() and Input.is_action_just_pressed("skip_story"):
		$StoryLabel.visible_characters = -1
		$TypingTimer.stop()
		$ContinueButton.visible = true

func _on_typing_timer_timeout():
	$StoryLabel.visible_characters += 1
	if $StoryLabel.visible_characters == $StoryLabel.text.length():
		$TypingTimer.stop()
		$WaitTimer.start()

func _on_wait_timer_timeout():
	$ContinueButton.visible = true
	
func start_typing():
	$StoryLabel.visible_characters = 0
	$ContinueButton.visible = false
	$TypingTimer.start()
