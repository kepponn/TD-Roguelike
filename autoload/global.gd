extends Node

var final_target

var currency: int = 9999

var preparation_phase: bool = true
var is_pathReachable: bool

var life_array : Array = []

#Enemy
var spawn_position
# var base_enemiesCount: int = 2 # This is unused because we're moving into using count_enemies() with weight seeder
var wave_weight_limit: int = 10 # This is the starting weight maybe increment by 2 every wave?
var total_enemies: int #Total of enemies will be spawned in this waves
var enemy_left: int #Count enemy left (alive) spawned or not spawned yet
var enemy_spawned: int #Count spawned enemy
var waves: int = 1


