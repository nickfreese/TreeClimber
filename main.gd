extends Node2D

@onready var TreeClimber = $TreeClimber
@onready var UI = $UI
@onready var ChooseFile = $ChooseFile
@onready var bg = $Bg

var current_text = ""
var options = []

var itemListSelected = null
var gameStarted = false
var opened_file_event = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var screen_size = get_viewport_rect().size
	bg.set_size(screen_size)
	ChooseFile.current_dir = OS.get_system_dir(2)
	UI.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("enter") and self.gameStarted == true and self.UI.visible and itemListSelected != null and self.opened_file_event == false:
		item_action(self.itemListSelected, 0, 0)
	
	self.opened_file_event = false
		


func item_action(index, at_position, mouse_button_index):
	if self.gameStarted == false:
		return false
	self.TreeClimber.selectOption(index)
	if self.TreeClimber.goToNextInteraction() != null:
		var interaction = self.TreeClimber.getActiveContent().interactions[self.TreeClimber.data.active_interaction]
		self.UI.setText(self.TreeClimber.processText(interaction.text))
		self.UI.setSourceText(self.TreeClimber.getInteractionSource())
		self.UI.populateList(interaction.options)
		self.itemListSelected = 0
	else:
		self.TreeClimber.moveToNextContent()
		if self.TreeClimber.getActiveContent() == null:
			self.UI.setText("Game Over")
			self.UI.hideList()
			self.gameStarted = false
			return null
		self.TreeClimber.goToNextInteraction()
		var interaction = self.TreeClimber.getActiveContent().interactions[self.TreeClimber.data.active_interaction]
		self.UI.setText(self.TreeClimber.processText(interaction.text))
		self.UI.setSourceText(self.TreeClimber.getInteractionSource())
		self.UI.populateList(interaction.options)
		self.itemListSelected = 0
		

# Main function  that moves us through the flow of the game
func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	item_action(index, at_position, mouse_button_index)
	
	
## choose a file
func _on_choose_file_file_selected(path):
	
	self.TreeClimber.load(path)
	
	self.TreeClimber.moveToNextContent()
	self.TreeClimber.goToNextInteraction()
	var interaction = self.TreeClimber.getActiveContent().interactions[self.TreeClimber.data.active_interaction]
	
	self.UI.setText(self.TreeClimber.processText(interaction.text))
	self.UI.setSourceText(self.TreeClimber.getInteractionSource())
	self.UI.populateList(interaction.options)
	self.itemListSelected = 0
	
	self.gameStarted = true
	UI.visible = true
	self.opened_file_event = true
	

func _on_choose_file_canceled():
	ChooseFile.visible = false


func _on_item_list_item_selected(index):
	itemListSelected = index
