extends Control

@onready var choiceButton = preload("res://UI/dialogue/choice_button.tscn")
@onready var ezDialogue := $EzDialogue
@onready var buttonHolder = $TextureRect/choiceBox/ButtonHolder
@onready var label = $TextureRect/textBox/Label
@onready var state = {}
@export var dialogue_json: JSON

var choiceButtons: Array[Button] = []

func _ready() -> void:
	ezDialogue.start_dialogue(dialogue_json, state)

func clear_dialogue_box():
	label.text = ""
	for choice in choiceButtons:
		buttonHolder.remove_child(choice)
	choiceButtons = []

func add_text(newText: String):
	$TextureRect/textBox/Label.text = newText

func add_choice(choice_text: String):
	var buttonObj: ChoiceButton = choiceButton.instantiate()
	buttonObj.choice_index = choiceButtons.size()
	choiceButtons.push_back(buttonObj)
	buttonObj.text = choice_text
	buttonObj.choice_selected.connect(_on_choice_selected)
	buttonHolder.add_child(buttonObj)

func _on_choice_selected(choice_index: int):
	ezDialogue. next(choice_index)

func _on_ez_dialogue_dialogue_generated(response: DialogueResponse) -> void:
	clear_dialogue_box()
	add_text(response.text)
	if response.choices.is_empty():
		add_choice("...")
	else:
		for choice in response.choices:
			add_choice(choice)

func _hide():
	clear_dialogue_box()
	hide()

func _on_ez_dialogue_custom_signal_received(value: Variant) -> void:
	if value == "end":
		_hide()
