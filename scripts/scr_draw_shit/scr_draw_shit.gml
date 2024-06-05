function draw_empty (x, y, rx, ry=rx)
{
	draw_primitive_begin(pr_linelist)
	draw_vertex(x-rx, y)
	draw_vertex(x+rx, y)
	draw_vertex(x, y-ry)
	draw_vertex(x, y+ry)
	draw_primitive_end()
}

///@arg {Struct.Rect} rect
///@arg {Struct.Circle} circle
///@arg {Bool} outline
function draw_rect_diamond_diff (rect, c, outline)
{
	//var cx = c.co.x
	//var cy = c.co.y
	var r = c.radius
	var x0 = rect.x0
	var y0 = rect.y0
	var x1 = rect.x1
	var y1 = rect.y1
	
	if outline
	{
		draw_primitive_begin(pr_linestrip)
		
		draw_vertex(x0-r, y0)
		draw_vertex(x0, y0-r)
		draw_vertex(x1, y0-r)
		draw_vertex(x1+r, y0)
		draw_vertex(x1+r, y1)
		draw_vertex(x1, y1+r)
		draw_vertex(x0, y1+r)
		draw_vertex(x0-r, y1)
		draw_vertex(x0-r, y0)
	}
	else
	{
		draw_primitive_begin(pr_trianglefan)
		draw_vertex(x0-r, y0)
		draw_vertex(x0, y0-r)
		draw_vertex(x1, y0-r)
		draw_vertex(x1+r, y0)
		draw_vertex(x1+r, y1)
		draw_vertex(x1, y1+r)
		draw_vertex(x0, y1+r)
		draw_vertex(x0-r, y1)
	}
	draw_primitive_end()
	
}

///@arg {Real} x
///@arg {Real} y
///@arg {Real} radius
///@arg {Bool} outline
function draw_diamond (_x, _y, r, outline)
{
	if outline
	{
		draw_primitive_begin(pr_linestrip)
		draw_vertex(_x-r, _y)
		draw_vertex(_x, _y-r)
		draw_vertex(_x+r, _y)
		draw_vertex(_x, _y+r)
		draw_vertex(_x-r, _y)
	}
	else
	{
		draw_primitive_begin(pr_trianglestrip)
		draw_vertex(_x-r, _y)
		draw_vertex(_x, _y-r)
		draw_vertex(_x, _y+r)
		draw_vertex(_x+r, _y)
	}
	draw_primitive_end()
}

///@arg {Real} x0
///@arg {Real} y0
///@arg {Real} x1
///@arg {Real} y1
///@arg {Bool} outline
function draw_rect (x0, y0, x1, y1, outline)
{
	if outline
	{
		draw_primitive_begin(pr_linestrip)
		draw_vertex(x0, y0)
		draw_vertex(x1, y0)
		draw_vertex(x1, y1)
		draw_vertex(x0, y1)
		draw_vertex(x0, y0)
	}
	else
	{
		draw_primitive_begin(pr_trianglestrip)
		draw_vertex(x0, y0)
		draw_vertex(x1, y0)
		draw_vertex(x0, y1)
		draw_vertex(x1, y1)
	}
	draw_primitive_end()
}
