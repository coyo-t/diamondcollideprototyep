
#macro SHOW_SHAPES 1
#macro SHOW_DIFFS 2
#macro SHOW_FLAGS score

SHOW_FLAGS = SHOW_DIFFS

var r = new Rect(0,0,1,1)
collider = r

shape = new Circle(0, 0, 128)

origin = shape.co
direct = new Vec(1, 1)

shade_fac = 0.5
altering_fac = false

with obj_collider
{
	r.x0 = bbox_left
	r.y0 = bbox_top
	r.x1 = bbox_right
	r.y1 = bbox_bottom
}

