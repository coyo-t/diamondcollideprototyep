
altering_fac = false

SHOW_FLAGS ^= SHOW_SHAPES * keyboard_check_pressed(ord("1"))
SHOW_FLAGS ^= SHOW_DIFFS  * keyboard_check_pressed(ord("2"))

var mwh = mouse_wheel_down() - mouse_wheel_up()

if mwh <> 0
{
	shape.radius = clamp(shape.radius + mwh * 4, 8, 128)
	
}

var ctrldown = keyboard_check(vk_control)
var shiftdown = keyboard_check(vk_shift)

if keyboard_check(ord("Q"))
{
	shade_fac = clamp((mouse_x - 32) / (room_width - 64), 0, 1)
	altering_fac = true
}
else if ctrldown or shiftdown
{
	var dx = window_mouse_get_delta_x()
	var dy = window_mouse_get_delta_y()
	var x0 = collider.x0
	var y0 = collider.y0
	var x1 = collider.x1
	var y1 = collider.y1
	
	if shiftdown
	{
		x0 += dx
		y0 += dy
	}
	if ctrldown
	{
		x1 += dx
		y1 += dy
	}
	
	collider.x0 = min(x0, x1)
	collider.x1 = max(x0, x1)
	collider.y0 = min(y0, y1)
	collider.y1 = max(y0, y1)
}
else
{
	if mouse_check_button(mb_right)
	{
		if !keyboard_check(vk_alt)
		{
			direct.x = origin.x+direct.x-mouse_x
			direct.y = origin.y+direct.y-mouse_y
		}
		origin.x = mouse_x
		origin.y = mouse_y
	}

	if mouse_check_button(mb_left)
	{
		direct.x = mouse_x-origin.x
		direct.y = mouse_y-origin.y
	}
}
