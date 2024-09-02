# TreeClimber Schema


## Top level keys

| Key    | type | default | description |
| -------- | ------- | ------- | ------- |
| **active** | int / null   | null | Holds the ID of the active content object |
| **active_interaction** | int / null   | null | Holds the ID of the active interaction object |
| **content_seen** | array/list | `[]` | A list of all content objects that have been seen |
| **state**    | object/dict | `{}` | an object of key values pairs that define the game's state |
| **sources**    | array/list | `[]` | A list of [source](#sources) objects that define characters or voices in the game |
| **map**    | array/list | `[]` | A list of [content](#map) objects that define conversations, or descrete pieces of game content |
| **load_tree** (Beta)    | object/dict | `{}` | An object of key value pairs where the keys are boolean state variables and the values are file paths to addtional list of JSON content |


### sources
| Key    | type | default | description |
| -------- | ------- | ------- | ------- |
| **id** | int  | | A unique integer ID for our source |
| **name** | string  | `""` | The name of the source.  Generally should be a front facing name |
| **meta** | object/dict | `{}` | Any additional data we want to store for our source |



### map
(content objects)

| Key    | type | default | description |
| -------- | ------- | ------- | ------- |
| **id** | int  | | A unique integer ID for the content |
| **name** | string  | `""` | The name of the content.  Mostly to improve readability |
| **once** | bool  | false | Whether or not the content can be activated more than once |
| **deps** | array/list  | [] | A list of dependency objects that are used in deciding whether the game meets its state requirements to be viewed |
| **interactions** | array/list  | [] | A list dialog objects that define specific steps in the dialog tree, their available options, and state variable results |
| **meta** | object/dict | `{}` | Any additional data we want to store for the content |


### deps
There are two types of dependency objects
1.
| Key    | type | description |
| -------- | ------- | ------- |
| **type** | string  | value = content_id |
| **id** | int  | The id of the content that must have been seen to view this content |

2.
| Key    | type | description |
| -------- | ------- | ------- |
| **type** | string  | value = state_id |
| **id** | string  | The key of the state variable to match |
| **value** | string  | The value to match on the state variable |


### interactions
| Key    | type | default | description |
| -------- | ------- | ------- | ------- |
| **deps** | array/list  | [] | A list of dependency objects that are used in deciding whether the game meets its state requirements to view this interaction |
| **source_id** | string  |  `""` | the id of the source object (character who is speaking) |
| **text** | string  |  `""` | The dialog to be displayed for this interaction |
| **state_id** | string  | `""` | the key of a state variable that viewing this interaction should update |
| **state_value** | any  | `null` | the value of a state variable that viewing this interaction should be updated to |
| **options** | array/list  | []  | A list of option objects that define responses to and consequences of the iteraction |


### options

| Key    | type | default | description |
| -------- | ------- | ------- | ------- |
| **test** | string  | `""` | The text to be shown for this option |
| **state_id** | array/list  | [] | an array of keys of the state variables that viewing this interaction should update |
| **state_value** | array/list  | [] | an array of values of the state variables that viewing this interaction should be updated to |
| **state_conditions** | array/list  | [] | an array conditions objects that will be used to determine whether the particular state variable should be updated |
| **state_add** | array/list  | [] | an array of booleans that define whether the `state_value`'s should be added to the existing value, or replace them  |

**note** -  all state related fields utilize a parralel index pattern.  meaning state_id's are stored in one array, and state_value in another.  To get the id-value pair, you must use the same index on both.  
The reason for this pattern is to reduce nesting and increase readability of the schema. 


### conditions
This is a very powerful conditions engine for creating complex if statements that dictate whether a state variable is updated. 

| Key    | type | default | description |
| -------- | ------- | ------- | ------- |
| **group** | array/list  | [] | A list objects that define an id and a type for AND and OR groups. eg: `{"type":"and","id":"and_1"}`  |
| **state_id** | array/list  | [] | array of keys of state variables to match against |
| **state_value** | array/list  | [] | an array values of state variables we'll match against |
| **operator** | array/list  | [] | an array of operators used for comparing our state variables and our values |

#### condition example 1
```
{
   "group":[
	  {
		"type":"and",
		"id":"and_1"
	  },
	  {
		"type":"and",
		"id":"and_1"
	  }
	],
	"state_id":["player_1_name", "score"],
	"state_value":["Sam", 5],
	"operator":["==", ">"]
}
```
Would result in an iff statement like this

```
if (state.player_1_name == "Sam" AND state.score > 5):
```

#### condition example 2
```
{
   "group":[
	  {
		"type":"and",
		"id":"and_1"
	  },
	  {
		"type":"or",
		"id":"or_1"
	  },
	  {
		"type":"or",
		"id":"or_1"
	  }
	],
	"state_id":["player_1_name", "score", "player_level"],
	"state_value":["Sam", 5, 9000],
	"operator":["==", ">", ">"]
}
```
Would result in an iff statement like this:
	
```
if (state.player_1_name == "Sam") AND (state.score > 5 or state.player_level > 9000 ):
```
We We can see here that groups are evaluated first and then each group is evaluated against the others as an AND
