extends Node


@onready
var pointA = $PointA

@onready
var pointB = $PointB

@onready
var mainCharacter = get_tree().get_first_node_in_group("MainCharacter")

@onready
var distanceToMC = 0.0
@onready
var distanceToA = 0.0
@onready
var distanceToB = 0.0

@export
var highlightDistance = 80;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateDistanceToMC()
	if distanceToMC < highlightDistance:
		pointA.get_child(0).enableHighlight()
		pointB.get_child(0).enableHighlight()
	else:
		pointA.get_child(0).disableHighlight()
		pointB.get_child(0).disableHighlight()	
	#pass

func updateDistanceToMC():
	distanceToA = pointA.position.distance_to(mainCharacter.position)
	distanceToB = pointB.position.distance_to(mainCharacter.position)
	
	distanceToMC = min(distanceToA, distanceToB)
	
func getDistanceToMC():
	return distanceToMC

func getSortedByDistance():
	if distanceToA > distanceToB:
		return [pointB, pointA]
	else:
		return [pointA, pointB]
	
	
