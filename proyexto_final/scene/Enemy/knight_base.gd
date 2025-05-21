extends CharacterBody2D

#region handlers
@onready var flip_handler: FlipHandler = $FlipHandler
@onready var gravity_handler: GravityHandler = $GravityHandler
@onready var movement_handler: MovementHandler = $MovementHandler
@onready var ai_handler: AIHandler = $AIHandler
@onready var death_handler: DeathHandler = $DeathHandler
@onready var drop_handler: DropHandler = $DropHandler
@onready var health_handler: HealthHandler = $HealthHandler
@onready var hurt_box: HurtBox = $HurtBox
@onready var hit_box_handler: HitBoxHandler = $HitBoxHandler
#endregion

@onready var animatedSprite2D: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_attacking: bool = false
var is_player_in_range: bool = false
var is_dying: bool = false
var player: Player = null

func _ready() -> void:
	hurt_box.area_entered.connect(on_player_hit)
	detection_area.body_entered.connect(_on_detection_area_entered)
	detection_area.body_exited.connect(_on_detection_area_exited)
	SignalBus.on_player_ready.connect(func(p): player = p)
	SignalBus.on_player_respawned.connect(_on_player_respawned)

func _physics_process(delta: float) -> void:
	if player and player.health_handler.current_health <= 0:
		is_dying = true
		return
		
	if is_attacking or health_handler.is_dead or is_dying:
		return

	gravity_handler.apply_gravity(self, delta)
	ai_handler.handle_state(self, delta)
	move_and_slide()
	flip_handler.handle_flip(self)

func on_player_hit(area: Area2D) -> void:
	drop_handler.add_coin(1)

func _on_detection_area_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = true

		if body.global_position.x < global_position.x:
			velocity.x = -1
		else:
			velocity.x = 1

		flip_handler.handle_flip(self)

		if not is_attacking and not is_dying:
			attack_loop()

func _on_detection_area_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false

func attack_loop() -> void:
	if is_attacking or health_handler.is_dead or is_dying:
		return
		
	is_attacking = true

	while is_player_in_range and not health_handler.is_dead and not is_dying:
		print("👊 Atacando jugador")
		hit_box_handler.collision_shape_2d.set_deferred("disabled", false)
		animatedSprite2D.play("hit")
		await animatedSprite2D.animation_finished
		hit_box_handler.collision_shape_2d.set_deferred("disabled", true)

		if not is_player_in_range or health_handler.is_dead:
			break

		await get_tree().create_timer(1.0).timeout

	is_attacking = false
	if not health_handler.is_dead and not is_dying:
		animatedSprite2D.play("walk")

func play_death_animation() -> void:
	print("💀 Reproduciendo animación 'die'")
	is_dying = true
	is_attacking = false
	
	if audio:
		audio.play()
		await get_tree().create_timer(0.2).timeout
		audio.stop()
		
	animatedSprite2D.play("die")
	await animatedSprite2D.animation_finished
	queue_free()


func _on_player_respawned() -> void:
	print("🔁 Jugador revivió, reactivando enemigo")
	is_dying = false
