
var show_shapes = (SHOW_FLAGS & SHOW_SHAPES) != 0
var show_diffs  = (SHOW_FLAGS & SHOW_DIFFS)  != 0

var ox = origin.x
var oy = origin.y
var dx = direct.x
var dy = direct.y
var gx = ox+dx
var gy = oy+dy

if altering_fac
{
	draw_set_colour(c_dkgrey)
	draw_set_alpha(.4)
	draw_line(32, 0, 32, room_height)
	draw_line(room_width-32, 0, room_width-32, room_height)
}



var dbtext = ""
var clipped_x = gx
var clipped_y = gy
var normal_x = 0
var normal_y = 0

if show_diffs
{
	var r = shape.radius
	draw_set_colour(c_dkgrey)
	draw_set_alpha(0.25)
	draw_rect_diamond_diff(collider, shape, false)
	
	draw_primitive_begin(pr_linelist)
	var x0 = collider.x0
	var y0 = collider.y0
	var x1 = collider.x1
	var y1 = collider.y1
	var gx0 = x0-r
	var gy0 = y0-r
	var gx1 = x1+r
	var gy1 = y1+r
	draw_vertex(gx0, 0)
	draw_vertex(gx0, room_height)
	draw_vertex(gx1, 0)
	draw_vertex(gx1, room_height)
	
	draw_vertex(0, gy0)
	draw_vertex(room_width, gy0)
	draw_vertex(0, gy1)
	draw_vertex(room_width, gy1)
		
	var cr = 512

	draw_set_colour(c_dkgrey)
	draw_set_alpha(0.75)
	draw_vertex(gx0-cr, y0+cr)
	draw_vertex(x0+cr, gy0-cr)
	draw_vertex(gx1-cr, y0-cr)
	draw_vertex(x1+cr, gy0+cr)

	draw_vertex(gx0-cr, y1-cr)
	draw_vertex(x0+cr, gy1+cr)
	draw_vertex(gx1-cr, y1+cr)
	draw_vertex(x1+cr, gy1-cr)

	draw_vertex(x0, 0)
	draw_vertex(x0, room_height)
	draw_vertex(x1, 0)
	draw_vertex(x1, room_height)
	
	draw_vertex(0, y0)
	draw_vertex(room_width, y0)
	draw_vertex(0, y1)
	draw_vertex(room_width, y1)
	
	draw_set_colour(c_white)
	draw_set_alpha(0.5)
	var hw = (x1-x0)*0.5
	var hh = (y1-y0)*0.5
	var cx = x0+hw
	var cy = y0+hh
	
	draw_vertex(cx, 0)
	draw_vertex(cx, room_height)
	draw_vertex(0, cy)
	draw_vertex(room_width, cy)
	
	draw_primitive_end()
	
	var relx = ox-cx
	var rely = oy-cy
	var quadx = relx < 0 ? -1 : +1
	var quady = rely < 0 ? -1 : +1
	relx = abs(relx)
	rely = abs(rely)
	
	var absgx = abs(gx-cx)
	var absgy = abs(gy-cy)
	var reldestx = relx+dx*quadx
	var reldesty = rely+dy*quady
	
	var origin_behind_slope = relx-hw+rely-hh <= r
	
	draw_set_colour((reldestx-hw+reldesty-hh) <= r ? c_green : c_grey)
	draw_set_alpha(0.75)
	draw_circle(absgx+cx, absgy+cy, 8, true)
	
	draw_set_alpha(0.25)
	draw_primitive_begin(pr_trianglelist)
	if origin_behind_slope
	{
		// origin is in r4, r5, r2, r3, r9, or r0
		if relx <= hw and rely > hh + r
		{
			// origin is in r4
			var dxreal = dx*quadx
			var dyreal = dy*quady
			var dp1 = dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx)
			var dp2 = dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx))
			// if the endpoint is above the bounds of the inflated box, no intersection is possible
			var collision_possible = rely+dyreal <= hh+r and dp1 < 0 and dp2 < 0
			dbtext = string_join("\n",
				$"{dp1}",
				$"{dp2}",
				$"{collision_possible ? "true" : "false"}",
			)
			
			if collision_possible
			{
				var time = (hh+r-rely) / dyreal
				clipped_x = ox+dx*time
				clipped_y = (hh+r)*quady+cy
				normal_x = 0
				normal_y = quady
			}
			
			draw_set_colour(collision_possible ? c_green : c_orange)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx, hh+cy+r)
			draw_vertex(-hw+cx, hh+cy+r)
		}
		else if rely <= hh and relx > hw + r
		{
			// origin is in r5
			
			var dxreal = dx*quadx
			var dyreal = dy*quady
			var dp1 = dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx))
			var dp2 = dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx)
			// if the endpoint is above the bounds of the inflated box, no intersection is possible
			var collision_possible = relx+dxreal <= hw+r and dp1 < 0 and dp2 < 0
			dbtext = string_join("\n",
				$"{dp1}",
				$"{dp2}",
				$"{collision_possible ? "true" : "false"}",
			)
			
			if collision_possible
			{
				var time = (hw+r-relx) / dxreal
				clipped_y = oy+dy*time
				clipped_x = (hw+r)*quadx+cx
				normal_x = quadx
				normal_y = 0
			}
			
			draw_set_colour(collision_possible ? c_green : c_orange)
			
			
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx+r, hh+cy)
			draw_vertex(hw+cx+r, -hh+cy)
		}
		// the rest of the regions are ignored
	}
	else if (relx > hw+r) or (rely > hh+r)
	{
		// origin is in r6, r7, or r8 (but not r1)
		draw_primitive_begin(pr_trianglelist)
		if relx < hw+r
		{
			// origin is in r6
			draw_set_colour(c_yellow)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx, hh+cy+r)
			draw_vertex(-hw+cx, hh+cy+r)

			draw_set_alpha(0.15)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx+r, hh+cy)
			draw_vertex(hw+cx, hh+cy+r)
		}
		else if rely < hh+r
		{
			// origin is in r7
			draw_set_colour(c_red)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx+r, hh+cy)
			draw_vertex(hw+cx+r, -hh+cy)
			
			draw_set_alpha(0.15)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx+r, hh+cy)
			draw_vertex(hw+cx, hh+cy+r)
		}
		else
		{
			// origin is in r8
			draw_set_colour(c_fuchsia)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx, hh+cy+r)
			draw_vertex(-hw+cx, hh+cy+r)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx+r, hh+cy)
			draw_vertex(hw+cx+r, -hh+cy)
			draw_set_alpha(0.15)
			draw_vertex(relx+cx, rely+cy)
			draw_vertex(hw+cx+r, hh+cy)
			draw_vertex(hw+cx, hh+cy+r)
		}
	}
	draw_primitive_end()
	
	//draw_set_alpha(0.25)
	draw_set_alpha(0.5)
	
	draw_arrow(
		relx+cx,
		rely+cy,
		reldestx+cx,
		reldesty+cy,
		16
	)
	
	draw_set_colour(c_dkgrey)
	draw_set_alpha(0.75)
	draw_rect_diamond_diff(collider, shape, true)
	
}

if show_shapes begin
	draw_set_colour(c_green)
	draw_set_alpha(0.25)
	collider.draw(false)
	draw_set_alpha(0.75)
	collider.draw(true)

	var r = shape.radius
	
	var orl = ox-r
	var ort = oy-r
	var orr = ox+r
	var orb = oy+r
	
	var gl = gx-r
	var gt = gy-r
	var gr = gx+r
	var gb = gy+r
	
	draw_set_colour(c_grey)
	draw_set_alpha(.5)
	draw_primitive_begin(pr_linelist)
	
	draw_vertex(orl, oy)
	draw_vertex(gl, gy)

	draw_vertex(orr, oy)
	draw_vertex(gr, gy)

	draw_vertex(ox, ort)
	draw_vertex(gx, gt)

	draw_vertex(ox, orb)
	draw_vertex(gx, gb)

	draw_primitive_end()

	draw_rect(orl, ort, orr, orb, true)
	draw_rect(gl, gt, gr, gb, true)
	
	var tgx = dx * shade_fac + ox
	var tgy = dy * shade_fac + oy
	
	// fac ghost
	draw_set_colour(c_dkgrey)
	draw_set_alpha(.25)
	draw_diamond(tgx, tgy, shape.radius, false)
	draw_set_alpha(.75)
	draw_diamond(tgx, tgy, shape.radius, true)

	draw_set_alpha(.5)
	draw_rect(tgx-r, tgy-r, tgx+r, tgy+r, true)

	// endp ghost
	draw_set_colour(c_grey)
	draw_set_alpha(.25)
	draw_diamond(gx, gy, shape.radius, false)
	draw_set_alpha(.75)
	draw_diamond(gx, gy, shape.radius, true)

	// real diamond
	draw_set_colour(c_white)
	draw_set_alpha(.25)
	shape.draw_as_diamond(false)
	draw_set_alpha(.75)
	shape.draw_as_diamond(true)

end

if show_diffs
{
	draw_set_colour(c_white)
	draw_set_alpha(.25)
	draw_empty(gx, gy, room_width, room_height)
	draw_line(ox, oy, gx, gy)
	draw_set_alpha(.75)
	draw_arrow(ox, oy, clipped_x, clipped_y, 16)
	draw_empty(gx, gy, shape.radius*0.5)
	var nsz = 32
	draw_set_colour(c_red)
	draw_arrow(clipped_x, clipped_y, clipped_x+normal_x*nsz, clipped_y+normal_y*nsz, 8)
}


if string_length(dbtext) != 0
{
	draw_set_colour(c_yellow)
	draw_set_alpha(1)
	draw_text(32, 32, dbtext)
	
}

draw_set_colour(c_white)
draw_set_alpha(1)
