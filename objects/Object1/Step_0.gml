
var winw = window_get_width()
var winh = window_get_height()
if room_width <> winw or room_height <> winh
{
	room_width  = max(winw, 1)
	room_height = max(winh, 1)
	display_set_gui_size(-1, -1)
	surface_resize(application_surface, winw, winh)
}

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
else if keyboard_check(ord("S"))
{
	var maxside = (max(collider.x1-collider.x0, collider.y1-collider.y0)+shape.radius)*1.5
	
	var angle = get_timer()/1000000*45
	origin.set(
		(collider.x0+collider.x1)*0.5+lengthdir_x(maxside, angle),
		(collider.y0+collider.y1)*0.5+lengthdir_y(maxside, angle)
	)
	
	angle += sin(get_timer()/1000000*2.92202)*(22.5*0.25)
	direct.set(
		-lengthdir_x(maxside*2, angle),
		-lengthdir_y(maxside*2, angle)
	)
}
else if keyboard_check(vk_space)
{
	direct.x = 0
	direct.y = room_height
	origin.x = mouse_x
	origin.y = 0
}
else if keyboard_check(vk_backspace)
{
	direct.x = room_width
	direct.y = 0
	origin.x = 0
	origin.y = mouse_y
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
