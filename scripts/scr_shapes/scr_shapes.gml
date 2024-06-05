function Vec (_x=0, _y=_x) constructor begin
	x = _x
	y = _y
end

function Rect (_x0, _y0, _x1, _y1) constructor begin
	x0 = _x0
	y0 = _y0
	x1 = _x1
	y1 = _y1
	
	static draw = function (outline)
	{
		draw_rect(x0, y0, x1, y1, outline)
	}
end

function Circle (_x, _y, _radius) constructor begin
	co = new Vec(_x, _y)
	radius = _radius
	
	static draw_as_diamond = function (outline)
	{
		draw_diamond(co.x, co.y, radius, outline)
	}
end

