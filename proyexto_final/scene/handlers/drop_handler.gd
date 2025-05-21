class_name DropHandler
extends Node2D

@onready var droppable : PackedScene  = preload("res://scene/colectables/base_coin.tscn")

var current_coin  =0

func _ready() -> void:
	current_coin = 0

func add_coin(val: int) ->void:
	current_coin +=val
	

func drop_coin() -> void:
	if current_coin <= 0:
		return
	var entity_container = NodeExtensions.get_entity_container()
	if entity_container == null:
		return
		
	var new_coin = droppable.instantiate()
	var parent : Node2D = get_parent()
	var parent_pos = parent.global_position
	
	entity_container.call_deferred("add_child", new_coin)
	new_coin.position = parent_pos

	
	
	
	
	
