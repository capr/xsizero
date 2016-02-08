
--X si Zero (The Game!!!)
--Autori: Ioana Popa & Cosmin Apreutesei. Public Domain.

if ... == 'xsizero' then return end --prevent using as module

local nw = require'nw'
local ffi = require'ffi'

--logica jocului -------------------------------------------------------------

local a = {
	{' ', ' ', ' '},
	{' ', ' ', ' '},
	{' ', ' ', ' '},
}

local function play_round(x, y, symbol) --'X', '0'
	if a[y][x] ~= ' ' then
		error'nu se poate'
	end
	a[y][x] = symbol
end

local function f(symbol)
	if symbol == ' ' then
		return '_'
	else
		return symbol
	end
end

local function show_board()
	for y=1,3 do
		print(f(a[y][1]), f(a[y][2]), f(a[y][3]))
	end
end

local function check_status()

	--verificam daca s-a castigat pe orizontala
	for y=1,3 do
		if
			a[y][1] == a[y][2] and
			a[y][2] == a[y][3] and
			a[y][1] ~= ' '
		then
			return 'castigat'
		end
	end

	--verificam daca s-a castigat pe verticala
	for x=1,3 do
		if
			a[1][x] == a[2][x] and
			a[2][x] == a[3][x] and
			a[1][x] ~= ' '
		then
			return 'castigat'
		end
	end

	--verificam daca s-a castigat pe diagonala
	if
		(
			a[1][1] == a[2][2] and
			a[2][2] == a[3][3] and
			a[1][1] ~= ' '
		) or
		(
			a[3][3] == a[2][2] and
			a[2][2] == a[1][1] and
			a[3][3] ~= ' '
		)
	then
		return 'castigat'
	end

	--verificam daca mai e loc pe tabla
	for x=1,3 do
		for y=1,3 do
			if a[y][x] == ' ' then
				return 'continuati'
			end
		end
	end

	--nu mai e loc pe tabla si nici nu s-a castigat
	return 'remiza'

end

local function test1()
	play_round(2, 2, 'X')
	print(check_status())

	play_round(1, 1, '0')
	print(check_status())

	play_round(1, 2, 'X')
	print(check_status())

	play_round(1, 3, '0')
	print(check_status())

	play_round(2, 1, 'X')
	print(check_status())

	play_round(2, 3, '0')
	print(check_status())

	play_round(3, 1, 'X')
	print(check_status())

	play_round(3, 3, 'X')
	print(check_status())

	play_round(3, 2, '0')
	print(check_status())

	if check_status() ~= 'remiza' then
		error'trebuia sa fie remiza'
	end

	show_board()
end

--interfata grafica ----------------------------------------------------------

local app = nw:app()

local win = app:window{
   cw = 400, ch = 300,
   title = 'X si Zero',
	--visible = false,
}

function win:repaint()

	local bmp = self:bitmap()
	local p = ffi.cast('uint8_t*', bmp.data)

	local function setpixel(x, y, r, g, b)
		x = math.floor(x)
		y = math.floor(y)
		if x > bmp.w - 1 then return end
		if y > bmp.h - 1 then return end
		p[(y * bmp.w + x) * 4 + 2] = r
		p[(y * bmp.w + x) * 4 + 1] = g
		p[(y * bmp.w + x) * 4 + 0] = b
	end

	local function rectangle(x0, y0, w, h, r, g, b)
		for y = y0, y0 + h - 1 do
			for x = x0, x0 + w - 1 do
				setpixel(x, y, r, g, b)
			end
		end
	end

	local function vline(x0, y0, length, thickness, r, g, b)
		rectangle(x0 - thickness / 2, y0, thickness, length, r, g, b)
	end

	local function hline(x0, y0, length, thickness, r, g, b)
		rectangle(x0, y0 - thickness / 2, length, thickness, r, g, b)
	end

	local function diagonal1(x0, y0, bb_length, thickness, r, g, b)
		local c = thickness
		local a = math.sqrt(c^2 / 2)
		local x1 = x0 + a / 2
		local y1 = y0 - a / 2
		a = math.floor(a)
		for i = 0, a - 1 do
			for j = 0, bb_length - 1 do
				setpixel(x1 - i + j, y1 + i + j, r, g, b) --primary pixels
			end
			for j = 0, bb_length - 2 do
				setpixel(x1 - i + j, y1 + i + j + 1, r, g, b) --in-between fill pixels
			end
		end
	end

	local function diagonal2(x0, y0, bb_length, thickness, r, g, b)
		local c = thickness
		local a = math.sqrt(c^2 / 2) --teorema lui pitagora
		local x1 = x0 + a / 2
		local y1 = y0 - a / 2
		a = math.floor(a) --a is from a^2 + a^2 = c^2
		for i = 0, a - 1 do
			for j = 0, bb_length - 1 do
				setpixel(x1 + i - j, y1 + i + j, r, g, b) --primary pixels
			end
			for j = 0, bb_length - 2 do
				setpixel(x1 + i - j, y1 + i + j + 1, r, g, b) --in-between fill pixels
			end
		end
	end

	local function circle(cx, cy, radius, thickness, r, g, b)
		for i = -thickness / 2, thickness / 2 do
			for a = 0, 2 * math.pi, 0.001 do
				setpixel(
					cx + math.cos(a) * (radius + i),
					cy + math.sin(a) * (radius + i),
					r, g, b)
			end
		end
	end

	--center a rectangle in another
	local function center_rect(w1, h1, x, y, w, h)
		local x1 = (w - w1) / 2 + x
		local y1 = (h - h1) / 2 + y
		return x1, y1
	end

	--transform a point from (3*3) game space to (w*h) window space
	local function transform_point(x, y, x1, y1, w1, h1)
		local x2 = x / 3 * w1 - w1 / 6 + x1
		local y2 = y / 3 * h1 - h1 / 6 + y1
		return x2, y2
	end

	--board rectangle
	local w1, h1 = 200, 200
	local x1, y1 = center_rect(w1, h1, 0, 0, bmp.w, bmp.h)

	local function draw_zero(x, y)
		local cx, cy = transform_point(x, y, x1, y1, w1, h1)
		circle(cx, cy, 20, 4, 255, 255, 255)
	end

	local function draw_x(x, y)
		local t = 50
		local cx, cy = transform_point(x, y, x1, y1, w1, h1)
		local x2 = cx - t / 2
		local y2 = cy - t / 2
		diagonal1(x2, y2, t, 20, 255, 255, 255)
		local x2 = cx + t / 2
		diagonal2(x2, y2, t, 20, 255, 255, 255)
	end

	rectangle(x1, y1, w1, h1, 20, 20, 20)
	for x=0,3 do
		vline(x1 + x * (w1 / 3), y1, h1, 1, 255, 255, 255)
	end
	for y=0,3 do
		hline(x1, y1 + y * (h1 / 3), w1, 1, 255, 255, 255)
	end
	draw_zero(2, 2)
	draw_x(3, 3)

end

app:run()

