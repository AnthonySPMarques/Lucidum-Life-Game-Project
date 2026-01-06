extends Area2D
class_name PlayerHitbox

func enable_DefaultHitbox():
	%AHitboxMask.disabled = false
	%ADownHitboxMask.disabled = true
	%AWallSlideMask.disabled = true
	%ADashMask.disabled = true
	
	%HitboxMask.disabled = false
	%DownHitboxMask.disabled = true
	%WallSlideMask.disabled = true
	%DashMask.disabled = true
	
	#Disable only collision between enemies
	if %Hitbox.get_collision_mask_value(5) == false:
		%Hitbox.set_collision_mask_value(5, true)
	if %Hitbox.get_collision_mask_value(4) == false:
		%Hitbox.set_collision_mask_value(4, true)
	
func enable_DownHitbox():
	%ADownHitboxMask.disabled = false
	%AHitboxMask.disabled = true
	%AWallSlideMask.disabled = true
	%ADashMask.disabled = true
	
	%DownHitboxMask.disabled = false
	%HitboxMask.disabled = true
	%WallSlideMask.disabled = true
	%DashMask.disabled = true
	
	#Disable only collision between enemies
	if %Hitbox.get_collision_mask_value(5) == false:
		%Hitbox.set_collision_mask_value(5, true)
	if %Hitbox.get_collision_mask_value(4) == false:
		%Hitbox.set_collision_mask_value(4, true)
	
func enable_WallHitbox():
	%AWallSlideMask.disabled = false
	%AHitboxMask.disabled = true
	%ADownHitboxMask.disabled = true
	%ADashMask.disabled = true
	
	%WallSlideMask.disabled = false
	%HitboxMask.disabled = true
	%DownHitboxMask.disabled = true
	%DashMask.disabled = true
	
	#Disable only collision between enemies
	if %Hitbox.get_collision_mask_value(5) == false:
		%Hitbox.set_collision_mask_value(5, true)
	if %Hitbox.get_collision_mask_value(4) == false:
		%Hitbox.set_collision_mask_value(4, true)
	
func enable_DashHitbox():
	%ADashMask.disabled = false
	%AWallSlideMask.disabled = true
	%AHitboxMask.disabled = true
	%ADownHitboxMask.disabled = true
	
	%DashMask.disabled = false
	%WallSlideMask.disabled = true
	%HitboxMask.disabled = true
	%DownHitboxMask.disabled = true
	
	#Disable only collision between enemies
	if %Hitbox.get_collision_mask_value(5) == false:
		%Hitbox.set_collision_mask_value(5, true)
	if %Hitbox.get_collision_mask_value(4) == false:
		%Hitbox.set_collision_mask_value(4, true)
	
func disable_hitboxes():
	
	#Disable only collision between enemies
	if %Hitbox.get_collision_mask_value(5) == false:
		%Hitbox.set_collision_mask_value(5, true)
	if %Hitbox.get_collision_mask_value(4) == false:
		%Hitbox.set_collision_mask_value(4, true)
	
	#Loop all area2D children to disable every child mask
	for y in %Hitbox.get_children():
		y = y as CollisionShape2D
		y.disabled = true
