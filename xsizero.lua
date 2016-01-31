
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
   w = 400, h = 200,
   title = 'X si Zero',
	--visible = false,
}

function win:repaint()
	local bmp = self:bitmap()
	local p = ffi.cast('uint8_t*', bmp.data)

	local function setpixel(x, y, r, g, b)
		p[(y * bmp.w + x) * 4 + 2] = r
		p[(y * bmp.w + x) * 4 + 1] = g
		p[(y * bmp.w + x) * 4 + 0] = b
	end

	local function vline(x, y, length, r, g, b)
		--
	end

	local function hline(x, y, length, r, g, b)
		--
	end

	local function diagonal(x, y, bb_length, r, g, b)
		--
	end

	local function circle(cx, cy, r)
		--
	end

	for y=0,bmp.h-1 do
		for x=0,bmp.w-1 do
			p[(y * bmp.w + x) * 4 + 2] = 255
		end
	end
end

app:run()

