## Base class to represent a player's action. Extended by [CompareAction], 
## [SetAction], [MoveAction], etc.[br]
## We extend RefCounted so this object doesn't need to be freed manually later.
class_name PlayerAction
extends RefCounted
