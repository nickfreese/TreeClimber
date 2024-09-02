extends VBoxContainer

@onready var itemList = $ItemList
@onready var interactionText = $InteractionText
@onready var source = $Source

var text = ""
var options = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setSourceText(text):
	source.text = text + ":"
	
	
func setText(text):
	self.text = text
	self.interactionText.text = self.text

func hideList():
	self.itemList.visible = false

func populateList(options):
	self.itemList.clear()
	self.options = options
	
	var has_options = false;
	
	if options != null:
		if options.size() > 0:
			has_options = true
			
	if has_options:
		for i in range(options.size()):
			if i == 0:
				self.itemList.grab_focus()
			self.itemList.add_item(options[i].text)
	else:
		self.itemList.grab_focus()
		self.itemList.add_item(">")
	
		
	self.itemList.select(0)
	
