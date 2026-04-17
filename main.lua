-- pico-8 pinball
-- paste all sections into one tab

-- screen: 128x128
-- controls: z = left flipper, x = right flipper

function _init()
  reset_game()
end

function reset_game()
  score = 0
  balls = 3
  launch_ball()
  init_bumpers()
end

function launch_ball()
  bx = 64
  by = 20
  bdx = 1.2
  bdy = 0.5
  brad = 3
  alive = true
end

function init_bumpers()
  bumpers = {
    {x=30, y=40, r=6, pts=100},
    {x=64, y=30, r=6, pts=150},
    {x=98, y=40, r=6, pts=100},
  }
end

-- flipper setup
lf_px, lf_py = 22, 112
rf_px, rf_py = 106, 112
fl = 22
pi = 3.14

function flp_mirror(a) return pi - a end

lf_ang = 0.5
rf_ang = flp_mirror(0.5)
lf_target = 0.5
rf_target = flp_mirror(0.5)

function update_flippers()
  if btn(4) then
    lf_target = -0.4
  else
    lf_target = 0.5
  end
  if btn(5) then
    rf_target = flp_mirror(-0.4)
  else
    rf_target = flp_mirror(0.5)
  end
  lf_ang = lerp(lf_ang, lf_target, 0.35)
  rf_ang = lerp(rf_ang, rf_target, 0.35)
end

function lerp(a, b, t) return a + (b-a)*t end

function flipper_tip(px, py, ang, len)
  return px + cos(ang/(2*pi))*len,
         py + sin(ang/(2*pi))*len
end

function _update()
  if not alive then
    if btnp(4) or btnp(5) then
      if balls > 0 then
        launch_ball()
      else
        reset_game()
      end
    end
    return
  end

  update_flippers()

  bdy += 0.15

  bx += bdx
  by += bdy

  if bx < brad then bx=brad bdx=abs(bdx) end
  if bx > 128-brad then bx=128-brad bdx=-abs(bdx) end
  if by < brad+8 then by=brad+8 bdy=abs(bdy) end

  for b in all(bumpers) do
    local dx = bx-b.x
    local dy = by-b.y
    local dist = sqrt(dx*dx+dy*dy)
    if dist < brad+b.r then
      local nx = dx/dist
      local ny = dy/dist
      bx = b.x + nx*(brad+b.r+0.5)
      by = b.y + ny*(brad+b.r+0.5)
      local dot = bdx*nx + bdy*ny
      bdx = (bdx - 2*dot*nx)*1.1
      bdy = (bdy - 2*dot*ny)*1.1
      score += b.pts
    end
  end

  check_flipper(lf_px, lf_py, lf_ang, 1)
  check_flipper(rf_px, rf_py, rf_ang, -1)

  if by > 132 then
    alive = false
    balls -= 1
  end
end

function check_flipper(px, py, ang, side)
  local tx, ty = flipper_tip(px, py, ang, fl)
  local fx = tx-px local fy = ty-py
  local t = ((bx-px)*fx + (by-py)*fy) / (fx*fx+fy*fy)
  t = mid(0, t, 1)
  local cx = px+fx*t
  local cy = py+fy*t
  local dx = bx-cx
  local dy = by-cy
  local dist = sqrt(dx*dx+dy*dy)
  if dist < brad+2 then
    local nx = dx/dist
    local ny = dy/dist
    bx = cx + nx*(brad+2.5)
    by = cy + ny*(brad+2.5)
    local spd = sqrt(bdx*bdx+bdy*bdy)
    local dot = bdx*nx + bdy*ny
    bdx = bdx - 2*dot*nx
    bdy = bdy - 2*dot*ny
    if (side==1 and lf_ang < lf_target+0.05) or
       (side==-1 and rf_ang > rf_target-0.05) then
      bdy -= 2.5
    end
    bdy = min(bdy, -1)
  end
end

function _draw()
  cls(1)

  rect(0,8,127,127,5)

  for b in all(bumpers) do
    circfill(b.x, b.y, b.r, 10)
    circ(b.x, b.y, b.r, 7)
    print(b.pts/100, b.x-2, b.y-2, 7)
  end

  local ltx, lty = flipper_tip(lf_px, lf_py, lf_ang, fl)
  local rtx, rty = flipper_tip(rf_px, rf_py, rf_ang, fl)
  line(lf_px, lf_py, ltx, lty, 7)
  line(lf_px, lf_py+1, ltx, lty+1, 6)
  line(rf_px, rf_py, rtx, rty, 7)
  line(rf_px, rf_py+1, rtx, rty+1, 6)

  if alive then
    circfill(bx, by, brad, 7)
    circ(bx, by, brad, 6)
  end

  rectfill(0,0,127,7,0)
  print("score:"..score, 2, 1, 7)
  print("balls:"..balls, 90, 1, 7)

  if not alive then
    if balls > 0 then
      print("ball lost!", 40, 60, 8)
      print("z or x to serve", 28, 70, 7)
    else
      print("game over!", 40, 55, 8)
      print("score:"..score, 46, 65, 7)
      print("z or x to restart", 24, 75, 7)
    end
  end
end