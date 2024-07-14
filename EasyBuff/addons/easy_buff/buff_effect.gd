extends Resource
## An effect of a buff.
class_name BuffEffect

## A node path to the node that contains the property to be affected.
@export var NODE : String
## A property path to the property affected by the buff, begins from the Node at NODE.
@export var PROPERTY : String
## The Expression which will be executed when the effect is triggered, use PROPERTY to access the property affected.
@export var EXPRESSION : String


# Triggers the effect
func trigger(character : Node):
	var expression = Expression.new()
	var err = expression.parse(EXPRESSION, ["PROPERTY"])
	if err != OK:
		push_error("Cannot parse expression of effect " + resource_path)
		return
	var res = expression.execute([character.get_node(NODE).get_indexed(PROPERTY)])
	character.get_node(NODE).set_indexed(PROPERTY, res)
