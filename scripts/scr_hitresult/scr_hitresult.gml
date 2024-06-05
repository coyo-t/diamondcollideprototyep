#macro HR_ORIGIN_OUTSIDE     0
#macro HR_ORIGIN_OVERLAP     1
#macro HR_ORIGIN_ENCOMPASSED 2

function HitResult () constructor begin
	
	did_hit = false
	hit_time = 1.0
	clipped_co = new Vec()
	normal = new Vec()
	origin_status = HR_ORIGIN_OUTSIDE
	
	static clear = function ()
	{
		did_hit = false
		origin_status = HR_ORIGIN_OUTSIDE
	}
end
