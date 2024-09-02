# TreeClimber
Dialog tree and state management class.  Define your entire game's flow in a JSON object.

## What
There are two main components to TreeClimber

1. A JSON schema specification for defining dialog, state variables, and dialog sources (characters/voices)

2. A GD Script class that provides an API for modeling and traversal of the dialog tree.  Its main feature being that it uses the provided JSON definition to decide on the next piece of dialog or content based on game state requirements defined for that dialog or content.

## Why

combining state managemnt and dialog into a configuration format means you can define your game's content without tying it up in the programming of the game itself.  This free's you up to write and be creative with the flow of your game's story needing to program in specific features and game mechanics.


### Quick start

This Godot project is a basic impleemntation of TreeClimber that allows you to load in your own dialog tree and play through it.


## Schema

[Schema Documentation](JSON_SCHEMA.md)

Here is a simple game example
```
{
  "active": null,
  "active_interaction": null,
  "content_seen": [],
  "state": {
    "welcome": false
  },
  "sources": [
    {
      "id": 0,
      "name": "Player 1",
      "meta": {}
    }
  ],
  "map": [
    {
      "name": "welcome",
      "id": 0,
      "once": true,
      "deps": [],
      "interactions": [
        {
          "deps": [],
          "source_id": 1,
          "text": "Welcome, ready to play?",
          "options": [
            {
              "text": "Yes",
              "state_id": [
                "welcome",
                "score"
              ],
              "state_value": [
                true,
                1
              ]
            },
            {
              "text": "No",
              "state_id": [
                "welcome"
              ],
              "state_value": [
                false
              ]
            }
          ]
        },
        {
          "deps": [
            {
              "type": "state_id",
              "id": "welcome",
              "value": false
            }
          ],
          "source_id": 1,
          "text": "Goodbye",
          "state_id": [
            "some_id"
          ],
          "state_value": [
            true
          ],
          "options": []
        },
        {
          "deps": [
            {
              "type": "state_id",
              "id": "welcome",
              "value": true
            }
          ],
          "source_id": 1,
          "text": "Glad to here it.  What's your name?",
          "state_id": [
            "some_id"
          ],
          "state_value": [
            true
          ],
          "options": [
            {
              "text": "Dave",
              "state_id": [
                "player_1_name"
              ],
              "state_value": [
                "Dave"
              ],
              "state_add": [
                false
              ]
            },
            {
              "text": "Sam",
              "state_id": [
                "player_1_name",
                "score"
              ],
              "state_value": [
                "Sam",
                5
              ],
              "state_add": [
                false,
                true
              ]
            }
          ]
        }
      ],
      "meta": {}
    }
  ]
}
```

## API
Example of basic game flow
```
func _ready():
	self.TreeClimber.load(path)
	self.TreeClimber.moveToNextContent()
	self.TreeClimbergoToNextInteraction()
	var interaction = self.TreeClimber.getActiveContent().interactions[self.TreeClimber.data.active_interaction]
    # use the interaction object to display text and options

# choose an option
func choose_option(index):
	self.TreeClimber.selectOption(index)
	if self.TreeClimber.goToNextInteraction() != null:
			var interaction = self.TreeClimber.getActiveContent().interactions[self.TreeClimber.data.active_interaction]
			# use the interaction object to display text and options
	else:
			self.TreeClimber.moveToNextContent()
			self.TreeClimber.goToNextInteraction()
			var interaction = self.TreeClimber.getActiveContent().interactions[self.TreeClimber.data.active_interaction]
			# use the interaction object to display text and options

```

### API methods

| method name    | returns | arguments | description |
| -------- | ------- | ------- | ------- |
| **load** | schema object | file path to json | loads in a json file from the file system and sets it on the data property of TreeClimber |
| **setState** | value  | key, value | sets a game state value in `TreeClimber.data.state` |
| **getState** | value | key | gets a game state value from `TreeClimber.data.state` |
| **moveToNextContent** |  |  | moves the game state to the next available content |
| **getActiveContent** | content object |  | gets the active content object |
| **getAllAvailableContent** | content object list |  | gets all content objects which have saisfied dependencies |
| **goToNextInteraction** | interaction object |  | moves the game state to the next available interaction within the active object.  returns null when ther are no more interactions in the active content object |
| **getActiveInteraction** | interaction object |  | gets the active interaction from the active content object |
| **selectOption** | null | index integer | selects an option by its array index from the active interaction |
| **getInteractionSource** | string or source object | full_source boolean | returns the name of the source of the current interaction.  if full_source is passed as true, then the full source object is returned |



 
