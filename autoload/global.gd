extends Node

var final_target

var currency: int = 9999

var preparation_phase: bool = true
var preparation_time: int = 60 #preparation time given to player after every wave cleared
var is_pathReachable: bool

#Enemy
var spawn_position
var base_enemiesCount: int = 2 #base number of enemy
var total_enemies: int #Total of enemies will be spawned in this waves
var enemy_left: int #Count enemy left (alive) spawned or not spawned yet
var enemy_spawned: int #Count spawned enemy
var waves: int = 1

