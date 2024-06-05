
///@func Vec
function Vec (_x=0.0, _y=_x) constructor begin
	x = _x
	y = _y
	
	///@arg {Real} x
	///@arg {Real} y
	static set = function (x, y=_x)
	{
		self.x = x
		self.y = y
		return self
	}
end


///@func Rect
///@arg {Real} x0
///@arg {Real} y0
///@arg {Real} x1
///@arg {Real} y1
function Rect (x0, y0, x1, y1) constructor begin
	self.x0 = x0
	self.y0 = y0
	self.x1 = x1
	self.y1 = y1
	

	///@arg {Bool} outline
	static draw = function (outline)
	{
		draw_rect(x0, y0, x1, y1, outline)
	}

end


///@arg {Real} x
///@arg {Real} y
///@arg {Real} radius
function Circle (x, y, radius) constructor begin
	self.co = new Vec(x, y)
	self.radius = radius
	
	///@arg {Bool} outline
	static draw_as_diamond = function (outline)
	{
		draw_diamond(co.x, co.y, radius, outline)
	}
end

