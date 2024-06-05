
var show_shapes = (SHOW_FLAGS & SHOW_SHAPES) != 0
var show_diffs  = (SHOW_FLAGS & SHOW_DIFFS)  != 0

#macro CLIP_NONE   0
#macro CLIP_H      1
#macro CLIP_V      2
#macro CLIP_CORNER 3

#macro CLIP_FLAG_NONE 0
#macro CLIP_FLAG_R9   1
#macro CLIP_FLAG_R10  2
//#macro CLIP_FLAG_N90  1
//#macro CLIP_FLAG_P90  2


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
//var clipped_x = gx
//var clipped_y = gy
//var normal_x = 0
//var normal_y = 0
var hit_time = 1
//var did_hit = false

hitresult.clear()

// ray clipping
begin
	var r = shape.radius
	var hw, hh
	var cx, cy
	begin
		var x0 = collider.x0
		var y0 = collider.y0
		var x1 = collider.x1
		var y1 = collider.y1
		hw = (x1-x0)*0.5
		hh = (y1-y0)*0.5
		cx = x0+hw
		cy = y0+hh
		
		//begin // drawz
		//	draw_primitive_begin(pr_linelist)
		//	draw_set_colour(c_dkgrey)
		//	draw_set_alpha(0.25)
		//	var gx0 = x0-r
		//	var gy0 = y0-r
		//	var gx1 = x1+r
		//	var gy1 = y1+r
		//	draw_vertex(gx0, 0)
		//	draw_vertex(gx0, room_height)
		//	draw_vertex(gx1, 0)
		//	draw_vertex(gx1, room_height)
	
		//	draw_vertex(0, gy0)
		//	draw_vertex(room_width, gy0)
		//	draw_vertex(0, gy1)
		//	draw_vertex(room_width, gy1)
		
		//	var cr = 512

		//	draw_set_colour(c_dkgrey)
		//	draw_set_alpha(0.75)
		//	draw_vertex(gx0-cr, y0+cr)
		//	draw_vertex(x0+cr, gy0-cr)
		//	draw_vertex(gx1-cr, y0-cr)
		//	draw_vertex(x1+cr, gy0+cr)

		//	draw_vertex(gx0-cr, y1-cr)
		//	draw_vertex(x0+cr, gy1+cr)
		//	draw_vertex(gx1-cr, y1+cr)
		//	draw_vertex(x1+cr, gy1-cr)

		//	draw_vertex(x0, 0)
		//	draw_vertex(x0, room_height)
		//	draw_vertex(x1, 0)
		//	draw_vertex(x1, room_height)
	
		//	draw_vertex(0, y0)
		//	draw_vertex(room_width, y0)
		//	draw_vertex(0, y1)
		//	draw_vertex(room_width, y1)
	
		//	draw_set_colour(c_white)
		//	draw_set_alpha(0.5)
	
		//	draw_vertex(cx, 0)
		//	draw_vertex(cx, room_height)
		//	draw_vertex(0, cy)
		//	draw_vertex(room_width, cy)
	
		//	draw_primitive_end()
		//end
	end
	
	var relx = ox-cx
	var rely = oy-cy
	var quadx = relx < 0 ? -1 : +1
	var quady = rely < 0 ? -1 : +1
	relx = abs(relx)
	rely = abs(rely)

	var reldestx = relx+dx*quadx
	var reldesty = rely+dy*quady

	var clip_mode  = CLIP_NONE
	var clip_flags = CLIP_FLAG_NONE
	
	// origin is behind slope, so in r4, r5, or somewhere inside the shape we dont care about
	if relx-hw+rely-hh <= r
	{
		// origin is in r4
		if relx <= hw and rely > hh + r
		{
			dbtext = "R4"
			var dxreal = dx*quadx
			var dyreal = dy*quady
			// if the endpoint is above the bounds of the inflated box, no intersection is possible
			var collision_possible = (
				reldesty <= hh+r and
				// v0
				dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) < 0 and
				// v2
				dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx)) < 0
			)

			if collision_possible
			{
				clip_mode = CLIP_V
			}
		}
		// origin is in r5
		else if rely <= hh and relx > hw + r
		{
			dbtext = "R5"
			var dxreal = dx*quadx
			var dyreal = dy*quady
			// if the endpoint is above the bounds of the inflated box, no intersection is possible
			var collision_possible = (
				reldestx <= hw+r and
				// v1
				dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) < 0 and
				// v3
				dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) < 0
			)

			if collision_possible
			{
				clip_mode = CLIP_H
			}
		}
		// some region inside the shape, dont care
		else
		{
			// TODO: if origin is in i1, i0, or i2, report back that the diamond was overlapping
			// else, the diamond was fully encompassed by the box
			dbtext = "INSIDE"
		}
	}
	else
	{
		// origin is in r9 or r11
		if -hw-relx+rely-hh >= r
		{
			// TODO: apply mirroring
			// r9
			if relx < hw+r
			{
				dbtext = "R9"
				var dxreal = dx*quadx
				var dyreal = dy*quady
			
				var collision_possible = (
					reldesty <= hh+r and
					// v1
					dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) >= 0 and
					// v4
					dot_product(dxreal, dyreal, hh-rely, -(-hw-r-relx)) <= 0
				)
			
				if collision_possible
				{
					// > v0
					if dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) >= 0
					{
						if reldestx-hw+reldesty-hh <= r
						{
							clip_mode = CLIP_CORNER
						}
					}
					// > v2
					else if dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx)) >= 0
					{
						if -hw-reldestx+reldesty-hh < r
						{
							clip_mode = CLIP_CORNER
							clip_flags = CLIP_FLAG_R9
						}
					}
					else
					{
						clip_mode = CLIP_V
					}
				}
			}
			// r11
			else
			{
				dbtext = "R11"
				var dxreal = dx*quadx
				var dyreal = dy*quady
				
				var collision_possible = (
					reldestx <= hw+r and
					reldesty <= hh+r and
					reldestx-hw+reldesty-hh <= r and
					// v4
					dot_product(dxreal, dyreal, hh-rely, -(-hw-r-relx)) <= 0 and
					// v3
					dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx) <= 0
				)
				
				if collision_possible
				{
					// > v2, I3
					if dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx)) >= 0
					{
						clip_mode = CLIP_CORNER
						clip_flags = CLIP_FLAG_R9
					}
					// > v1, I2
					else if dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) <= 0
					{
						clip_mode = CLIP_H
					}
					// > v0, I1
					else if dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) <= 0
					{
						clip_mode = CLIP_V
					}
					else
					{
						clip_mode = CLIP_CORNER
					}
				}
			}
		}
		// origin is in r10 or r12
		else if relx-hw-hh-rely >= r
		{
			// TODO: apply mirroring
			// r10
			if rely < hh+r
			{
				dbtext = "R10"
				var dxreal = dx*quadx
				var dyreal = dy*quady
			
				var collision_possible = (
					reldestx <= hw+r and
					// v0
					dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) >= 0 and
					// v5
					dot_product(dxreal, dyreal, -(-hh-r-rely), hw-relx) <= 0
				)
			
				if collision_possible
				{
					// > v1
					if dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) >= 0
					{
						if reldestx-hw+reldesty-hh <= r
						{
							clip_mode = CLIP_CORNER
						}
					}
					// > v3
					else if dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx) >= 0
					{
						if reldestx-hw-hh-reldesty < r
						{
							clip_mode = CLIP_CORNER
							clip_flags = CLIP_FLAG_R10
						}
					}
					else
					{
						clip_mode = CLIP_H
					}
				}
			}
			// r12
			else
			{
				dbtext = "R12"
				var dxreal = dx*quadx
				var dyreal = dy*quady
				
				var collision_possible = (
					reldestx <= hw+r and
					reldesty <= hh+r and
					reldestx-hw+reldesty-hh <= r and
					// v5
					dot_product(dxreal, dyreal,  -(-hh-r-rely), hw-relx) <= 0 and
					// v2
					dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx)) <= 0
				)
				
				if collision_possible
				{
					// > v3, I4
					if dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx) >= 0
					{
						clip_mode = CLIP_CORNER
						clip_flags = CLIP_FLAG_R10
					}
					// > v0, I1
					else if dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) <= 0
					{
						clip_mode = CLIP_V
					}
					// > v1, I2
					else if dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) <= 0
					{
						clip_mode = CLIP_H
					}
					else
					{
						clip_mode = CLIP_CORNER
					}
				}
			}
		}
		// origin could be in r1, r6, r7, or r8
		else
		{
			switch (relx < hw+r ? 0b10 : 0) | (rely < hh+r ? 0b01 : 0)
			{
				// R8
				case 0b00: {
					dbtext = "R8"
					var dxreal = dx*quadx
					var dyreal = dy*quady
					var collision_possible = (
						reldestx<=hw+r and
						reldesty<=hh+r and
						reldestx-hw+reldesty-hh <= r and
						// v3
						dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx)) <= 0 and
						// v2
						dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx) <= 0
					)
			
					if collision_possible
					{
						// v1
						if dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) < 0
						{
							clip_mode = CLIP_H
						}
						// v0
						else if dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) < 0
						{
							clip_mode = CLIP_V
						}
						else
						{
							clip_mode = CLIP_CORNER
						}
					}
					break
				}
				// R6
				case 0b10: {
					dbtext = "R6"
					var dxreal = dx*quadx
					var dyreal = dy*quady
					var collision_possible = (
						reldesty <= hh+r and
						reldestx-hw+reldesty-hh <= r and
						// v1
						dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) >= 0 and
						// v3
						dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx)) <= 0
					)
					if collision_possible
					{
						// > v0
						if dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) >= 0
						{
							clip_mode = CLIP_CORNER
						}
						else
						{
							clip_mode = CLIP_V
						}
					}
					break
				}
				// R7
				case 0b01: {
					dbtext = "R7"
					var dxreal = dx*quadx
					var dyreal = dy*quady
					var collision_possible = (
						reldestx <= hw+r and
						reldestx-hw+reldesty-hh <= r and
						// v0
						dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) >= 0 and
						// v2
						dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx) <= 0
					)
					if collision_possible
					{
						// > v1
						if dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) >= 0
						{
							clip_mode = CLIP_CORNER
						}
						else
						{
							clip_mode = CLIP_H
						}
					}
					break
				}
				// R1
				case 0b11: {
					dbtext = "R1"
					// destination point is behind the slope
					// or is within the "visibility cone"
					// this could probably be computed better
					var dxreal = dx*quadx
					var dyreal = dy*quady
					var collision_possible = (
						(reldestx-hw+reldesty-hh <= r) and
						// v0
						(dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) >= 0) and
						// v1
						(dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) >= 0)
					)
		
					if collision_possible
					{
						clip_mode = CLIP_CORNER
					}
					break
				}
			}
		}
	}
	
	switch clip_mode
	{
		case CLIP_V: {
			hitresult.did_hit = true
			var dyreal = dy*quady
			hit_time = (hh+r-rely) / dyreal
			hitresult.clipped_co.set(
				ox+dx*hit_time,
				(hh+r)*quady+cy
			)
			hitresult.normal.set(0, quady)
			break
		}
		case CLIP_H: {
			hitresult.did_hit = true

			var dxreal = dx*quadx
			hit_time = (hw+r-relx) / dxreal
			hitresult.clipped_co.set(
				(hw+r)*quadx+cx,
				oy+dy*hit_time
			)
			hitresult.normal.set(quadx, 0)
			break
		}
		case CLIP_CORNER: {
			hitresult.did_hit = true
			
			var x0 = relx
			var y0 = rely
			var x1 = reldestx
			var y1 = reldesty
			
			switch clip_flags
			{
				case CLIP_FLAG_R9: {
					x0 = -x0
					x1 = -x1
					break
				}
				case CLIP_FLAG_R10: {
					y0 = -y0
					y1 = -y1
					break
				}
			}
			x0 -= hw
			y0 -= hh
			x1 -= hw
			y1 -= hh
			
			var cross = y0*x1-x0*y1
			var ddx = x1-x0
			var ddy = y1-y0
			
			hit_time = 1/abs((ddx+ddy)*r)
			var sqrr = r*r
			var crosx = ((+r*cross)-(ddx*sqrr))*hit_time
			var crosy = ((-r*cross)-(ddy*sqrr))*hit_time
			
			var sq = sqrt(0.5)
			
			switch clip_flags
			{
				case CLIP_FLAG_R9: {
					crosx = -(crosx+hw)
					crosy += hh
					hitresult.normal.set(
						quadx * -sq,
						quady * +sq,
					)
					break
				}
				case CLIP_FLAG_R10: {
					crosx += hw
					crosy = -(crosy+hh)
					hitresult.normal.set(
						quadx * +sq,
						quady * -sq,
					)
					break
				}
				default: {
					hitresult.normal.set(quadx * sq, quady * sq)
					crosx += hw
					crosy += hh
				}
			}
			
			hitresult.clipped_co.set(
				crosx*quadx+cx,
				crosy*quady+cy
			)

			break
		}
	}
	
end

#region old clip
/*
begin
	var r = shape.radius
	
	var x0 = collider.x0
	var y0 = collider.y0
	var x1 = collider.x1
	var y1 = collider.y1

	begin // drawz
		draw_primitive_begin(pr_linelist)
		draw_set_colour(c_dkgrey)
		draw_set_alpha(0.25)
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
	end
	
	var hw = (x1-x0)*0.5
	var hh = (y1-y0)*0.5
	var cx = x0+hw
	var cy = y0+hh
	
	var relx = ox-cx
	var rely = oy-cy
	var quadx = relx < 0 ? -1 : +1
	var quady = rely < 0 ? -1 : +1
	relx = abs(relx)
	rely = abs(rely)

	var reldestx = relx+dx*quadx
	var reldesty = rely+dy*quady
	
	var origin_behind_slope = relx-hw+rely-hh <= r

	var clip_mode = CLIP_NONE
	
	//var fuck = relx-hw-hh-rely
	//draw_arrow(hw+cx, -hh+cy, hw+cx, -hh+cy-fuck, 16)
	
	// origin is in r4, r5, r2, r3, r9, or r0
	if origin_behind_slope
	{
		// origin is in r4
		if relx <= hw and rely > hh + r
		{
			var dxreal = dx*quadx
			var dyreal = dy*quady
			// chamfer vertex
			var dp1 = dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx)
			// far vertex
			var dp2 = dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx))
			// if the endpoint is above the bounds of the inflated box, no intersection is possible
			var collision_possible = reldesty <= hh+r and dp1 < 0 and dp2 < 0

			if collision_possible
			{
				clip_mode = CLIP_V
			}
		}
		// origin is in r5
		else if rely <= hh and relx > hw + r
		{
			var dxreal = dx*quadx
			var dyreal = dy*quady
			// chamfer vertex
			var dp1 = dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx))
			// far vertex
			var dp2 = dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx)
			// if the endpoint is above the bounds of the inflated box, no intersection is possible
			var collision_possible = reldestx <= hw+r and dp1 < 0 and dp2 < 0

			if collision_possible
			{
				clip_mode = CLIP_H
			}
		}
		// the rest of the regions are ignored
	}
	// origin is in r6, r7, or r8 (but not r1)
	else if (relx > hw+r) or (rely > hh+r)
	{
		draw_primitive_begin(pr_trianglelist)
		// origin is in r6
		if relx < hw+r
		{
			var dxreal = dx*quadx
			var dyreal = dy*quady
			// horizontal (right) chamfer vertex
			var dph = dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx))
			// far vertex
			var dpf = dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx))
			
			collision_possible = (reldesty <= hh+r) and (reldestx-hw+reldesty-hh <= r) and (dph >= 0 and dpf <= 0)
			
			if collision_possible
			{
				// the ray is in the corner's cone
				if dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) >= 0
				{
					clip_mode = CLIP_CORNER
				}
				else
				{
					clip_mode = CLIP_V
				}
			}
		}
		// origin is in r7
		else if rely < hh+r
		{
			var dxreal = dx*quadx
			var dyreal = dy*quady
			// chamfer vertex
			var dpv = dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx) //>= 0
			// far vertex
			var dpf = dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx)
			
			collision_possible = (reldestx <= hw+r) and (reldestx-hw+reldesty-hh <= r) and (dpv >= 0)// and dpf <= 0)
			
			if collision_possible
			{
				// ray is in the corner's cone
				if dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx)) >= 0
				{
					clip_mode = CLIP_CORNER
				}
				else
				{
					// FIXME: this is a jank hack. this area should be considered its own region
					// origin is in the "sub region" r7-1 and the ray is in the opposing corner's cone
					// technically, its checking that its *not* in the far vertex's cone
					if relx-hw-hh-rely >= r and dpf > 0
					{
						clip_mode = CLIP_CORNER
						//dbtext = "CONE"
					}
					else
					{
						clip_mode = CLIP_H
					}
				}
			}
		}
		// origin is in r8
		else
		{
			var dxreal = dx*quadx
			var dyreal = dy*quady
			
			// far vertices
			var dph = dot_product(dxreal, dyreal, hh+r-rely, -(-hw-relx))
			var dpv = dot_product(dxreal, dyreal, -(-hh-rely), hw+r-relx)
			
			collision_possible = (
				(
					(reldestx<=hw+r and reldesty<=hh+r) and
					(reldestx-hw+reldesty-hh <= r)
				) and(dph <= 0 and dpv <= 0)
			)
			
			if collision_possible
			{
				dph = dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx))
				dpv = dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx)
				if dph < 0
				{
					clip_mode = CLIP_H
				}
				else if dpv < 0
				{
					clip_mode = CLIP_V
				}
				else
				{
					clip_mode = CLIP_CORNER
				}
			}
		}
	}
	// origin is in R1
	else
	{
		// destination point is behind the slope
		// or is within the "visibility cone"
		// this could probably be computed better
		var dxreal = dx*quadx
		var dyreal = dy*quady
		// vertical (top) chamfer
		var dp1 = dot_product(dxreal, dyreal, -(hh+r-rely), hw-relx)
		// horizontal (right) chamfer
		var dp2 = dot_product(dxreal, dyreal, hh-rely, -(hw+r-relx))
		collision_possible = (reldestx-hw+reldesty-hh <= r) and (dp1 >= 0 and dp2 >= 0)
		
		if collision_possible
		{
			clip_mode = CLIP_CORNER
		}
	}
	
	switch clip_mode
	{
		case CLIP_V: {
			var dyreal = dy*quady
			hit_time = (hh+r-rely) / dyreal
			clipped_x = ox+dx*hit_time
			clipped_y = (hh+r)*quady+cy
			normal_x = 0
			normal_y = quady
			did_hit = true
			break
		}
		case CLIP_H: {
			var dxreal = dx*quadx
			hit_time = (hw+r-relx) / dxreal
			clipped_y = oy+dy*hit_time
			clipped_x = (hw+r)*quadx+cx
			normal_x = quadx
			normal_y = 0
			did_hit = true
			break
		}
		case CLIP_CORNER: {
			var cross = (rely-hh) * (reldestx-hw) - (relx-hw) * (reldesty-hh)
			var ddx = reldestx-relx
			var ddy = reldesty-rely
			
			hit_time = 1/abs((ddx+ddy)*r)
			var sqrr = r*r
			var crosx = ((+r*cross)-(ddx*sqrr))*hit_time
			var crosy = ((-r*cross)-(ddy*sqrr))*hit_time
			
			clipped_x = (crosx+hw)*quadx+cx
			clipped_y = (crosy+hh)*quady+cy
			
			var sq = sqrt(0.5)
			
			normal_x = sq * quadx
			normal_y = sq * quady
			did_hit = true
			break
		}
	}
end
*/
#endregion

if show_diffs
{
	draw_set_colour(c_dkgrey)
	draw_set_alpha(0.25)
	draw_rect_diamond_diff(collider, shape, false)
	
	//draw_set_alpha(0.25)
	draw_set_alpha(0.5)
	
	//draw_arrow(
	//	relx+cx,
	//	rely+cy,
	//	reldestx+cx,
	//	reldesty+cy,
	//	16
	//)
	
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
	
	// casting shadow
	begin
		draw_set_colour(c_grey)
		draw_set_alpha(.5)
		draw_primitive_begin(pr_linelist)
		
		if abs(dx) > abs(dy)
		{
			draw_vertex(ox, ort)
			draw_vertex(gx, gt)

			draw_vertex(ox, orb)
			draw_vertex(gx, gb)
		}
		else
		{
			draw_vertex(orl, oy)
			draw_vertex(gl, gy)

			draw_vertex(orr, oy)
			draw_vertex(gr, gy)
		}

		draw_primitive_end()
	end
	
	//draw_rect(orl, ort, orr, orb, true)
	//draw_rect(gl, gt, gr, gb, true)
	

	
	// fac ghost
	if hitresult.did_hit
	{
		//var tgx = dx * shade_fac + ox
		//var tgy = dy * shade_fac + oy
		var cx = hitresult.clipped_co.x
		var cy = hitresult.clipped_co.y
		draw_set_colour(c_dkgrey)
		draw_set_alpha(.25)
		draw_diamond(cx, cy, shape.radius, false)
		draw_set_alpha(.75)
		draw_diamond(cx, cy, shape.radius, true)
	
		//draw_set_alpha(.5)
		//draw_rect(tgx-r, tgy-r, tgx+r, tgy+r, true)
	}
	
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
	//draw_empty(gx, gy, room_width, room_height)
	draw_arrow(ox, oy, gx, gy, 16)
	
	draw_set_alpha(.75)
	draw_empty(ox, oy, shape.radius*0.25)
	
	if hitresult.did_hit
	{
		var cx = hitresult.clipped_co.x
		var cy = hitresult.clipped_co.y
		var nx = hitresult.normal.x
		var ny = hitresult.normal.y
		draw_arrow(ox, oy, cx, cy, 16)
		//draw_empty(gx, gy, shape.radius*0.25)
		var nsz = 64
		draw_set_colour(c_red)
		draw_arrow(cx, cy, cx+nx*nsz, cy+ny*nsz, 8)
	}
	else
	{
		draw_arrow(ox, oy, gx, gy, 16)
		//draw_empty(gx, gy, shape.radius*0.25)
	}
}


//if string_length(dbtext) != 0
//{
//	draw_set_colour(c_yellow)
//	draw_set_alpha(1)
//	draw_text(32, 32, dbtext)
//}

draw_set_colour(c_white)
draw_set_alpha(1)
