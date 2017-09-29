
--X si Zero (The Game!!!)
--Autori: Ioana Popa & Cosmin Apreutesei. Public Domain.

if ... == 'xsizero' then return end --prevent using as module

local nw = require'nw'
local cairo = require'cairo'
local ffi = require'ffi'

--logica jocului -------------------------------------------------------------

local score_table = {
	['X'] = 0,
	['0'] = 0,
}

local board       -- {y -> {x -> 'X'|'0'|' '}}
local game_status -- 'continue', 'won', 'draw'
local winning_dir -- 'vertical', 'horizontal', 'diagonal1', 'diagonal2'
local winning_xy  --
local last_move   --

local function f(symbol)
	if symbol == ' ' then
		return '_'
	else
		return symbol
	end
end

local function show_board()
	for y=1,3 do
		print(f(board[y][1]), f(board[y][2]), f(board[y][3]))
	end
end

local function check_status()

	--verificam daca s-a castigat pe orizontala
	for y=1,3 do
		if
			board[y][1] == board[y][2] and
			board[y][2] == board[y][3] and
			board[y][1] ~= ' '
		then
			return 'won', 'horizontal', y
		end
	end

	--verificam daca s-a castigat pe verticala
	for x=1,3 do
		if
			board[1][x] == board[2][x] and
			board[2][x] == board[3][x] and
			board[1][x] ~= ' '
		then
			return 'won', 'vertical', x
		end
	end

	--verificam daca s-a castigat pe diagonala1
	if board[1][1] == board[2][2] and
		board[2][2] == board[3][3] and
		board[1][1] ~= ' '
	then
		return 'won', 'diagonal1'
	end

	--verificam daca s-a castigat pe diagonala2
	if board[1][3] == board[2][2] and
		board[2][2] == board[3][1] and
		board[1][3] ~= ' '
	then
		return 'won', 'diagonal2'
	end

	--verificam daca mai e loc pe tabla
	for x=1,3 do
		for y=1,3 do
			if board[y][x] == ' ' then
				return 'continue'
			end
		end
	end

	--nu mai e loc pe tabla si nici nu s-a castigat
	return 'draw'

end

local function play_round(x, y, symbol) --'X', '0'
	if game_status ~= 'continue' then
		print'nu se poate'
		return
	end
	if board[y][x] ~= ' ' then
		print'nu se poate'
		return
	end
	board[y][x] = symbol
	game_status, winning_dir, winning_xy = check_status()
	if game_status == 'won' then
		score_table[last_move] = score_table[last_move] + 1
	end
end

local function restart_game()
	board = {
		{' ', ' ', ' '},
		{' ', ' ', ' '},
		{' ', ' ', ' '},
	}
	game_status = 'continue'
	winning_dir = nil
	winning_xy  = nil
	last_move   = nil
end

restart_game()

--utils ----------------------------------------------------------------------

--center a rectangle in another
local function center_rect(w1, h1, x, y, w, h)
	local x1 = (w - w1) / 2 + x
	local y1 = (h - h1) / 2 + y
	return x1, y1
end

local function point_inside_rect(mx, my, x, y, w, h)
	return
		mx >= x and mx <= x + w and
		my >= y and my <= y + h
end

--interfata grafica ----------------------------------------------------------

local app = nw:app()

--center the window to the active screen
local win_cw, win_ch = 600, 300
local disp = app:active_display()
local x, y, w, h = disp:screen_rect()
local win_x, win_y = center_rect(win_cw, win_ch, x, y, w, h)

local win = app:window{
	x = win_x, y = win_y,
	cw = win_cw, ch = win_ch,
	title = 'X si Zero',
	--visible = false,
	resizeable = false,
	maximizable = false,
	fullscreenable = false,
}

local function board_rectangle()
	return 50, 50, 200, 200
end

--transform a point from (3*3) game space to (w*h) window space
local function map_point_to_window(x, y, x1, y1, w1, h1)
	local x2 = x / 3 * w1 - w1 / 6 + x1
	local y2 = y / 3 * h1 - h1 / 6 + y1
	return x2, y2
end

--transform a point from (w*h) window space to (3*3) game space
local function map_point_to_game(x, y, x1, y1, w1, h1)
	local x2 = math.floor(3 / (w1 - 1) * (x - x1)) + 1
	local y2 = math.floor(3 / (h1 - 1) * (y - y1)) + 1
	return x2, y2
end

local mouse_x, mouse_y = 0, 0
local left_mouse_button_pressed = false

function win:repaint()

	local bmp = self:bitmap()
	local cr = bmp:cairo()

	local p = ffi.cast('uint8_t*', bmp.data)

	local function setpixel(x, y, r, g, b)
		x = math.floor(x)
		y = math.floor(y)
		if x < 0 then return end
		if y < 0 then return end
		if x > bmp.w - 1 then return end
		if y > bmp.h - 1 then return end
		p[(y * bmp.w + x) * 4 + 2] = r
		p[(y * bmp.w + x) * 4 + 1] = g
		p[(y * bmp.w + x) * 4 + 0] = b
		p[(y * bmp.w + x) * 4 + 3] = 0xff
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
		local x1 = x0 - a / 2
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

	local x1, y1, w1, h1 = board_rectangle()

	local function draw_zero(x, y, r, g, b)
		local cx, cy = map_point_to_window(x, y, x1, y1, w1, h1)
		circle(cx, cy, 20, 15, r, g, b)
	end

	local function draw_x(x, y, r, g, b)
		local t = 50
		local cx, cy = map_point_to_window(x, y, x1, y1, w1, h1)
		local x2 = cx - t / 2
		local y2 = cy - t / 2
		diagonal1(x2, y2, t, 20, r, g, b)
		local x2 = cx + t / 2
		diagonal2(x2, y2, t, 20, r, g, b)
	end

	local function other_move(move)
		if move == 'X' then
			return '0'
		else
			return 'X'
		end
	end

	--aici incepe controller-ul -----------------------------------------------

	local mx, my = map_point_to_game(mouse_x, mouse_y, x1, y1, w1, h1)
	local inside_board = (mx >= 1 and mx <= 3 and my >= 1 and my <= 3)

	if left_mouse_button_pressed then
		if inside_board then
			if last_move == 'X' then
				last_move = '0'
			else
				last_move = 'X'
			end
			play_round(mx, my, last_move)
		end
	end

	local function text_extents(s)
		local ext = cr:text_extents(s)
		local ext_x = ext.x_bearing
		local ext_y = ext.y_bearing
		local ext_w = ext.width
		local ext_h = ext.height
		return ext_x, ext_y, ext_w, ext_h
	end

	--aici incepe View-ul -----------------------------------------------------

	--stergem ecranul
	rectangle(0, 0, bmp.w, bmp.h, 0, 0, 0)

	--desenam liniile gridului
	for x=1,2 do
		vline(x1 + x * (w1 / 3), y1, h1, 1, 255, 255, 255)
	end
	for y=1,2 do
		hline(x1, y1 + y * (h1 / 3), w1, 1, 255, 255, 255)
	end

	--desenam piesa curenta de sub mouse
	if inside_board and board[my][mx] == ' ' then
		local current_move = other_move(last_move)
		if current_move == 'X' then
			draw_x(mx, my, 50, 50, 50)
		elseif current_move == '0' then
			draw_zero(mx, my, 50, 50, 50)
		end
	end

	--desenam piesele
	for x = 1, 3 do
		for y = 1, 3 do
			local v = board[y][x]
			if v == 'X' then
				draw_x(x, y, 255, 255, 255)
			elseif v == '0' then
				draw_zero(x, y, 255, 255, 255)
			end
		end
	end

	--desenam linia aia rosie cand ai castigat
	if game_status == 'won' then
		if winning_dir == 'horizontal' then
			local x, y = map_point_to_window(0.5, winning_xy, x1, y1, w1, h1)
			hline(x, y, w1, 10, 255, 0, 0)
		elseif winning_dir == 'vertical' then
			local x, y = map_point_to_window(winning_xy, 0.5, x1, y1, w1, h1)
			vline(x, y, h1, 10, 255, 0, 0)
		elseif winning_dir == 'diagonal1' then
			local x, y = map_point_to_window(0.5, 0.5, x1, y1, w1, h1)
			diagonal1(x, y, w1, 10, 255, 0, 0)
		elseif winning_dir == 'diagonal2' then
			local x, y = map_point_to_window(3.5, 0.5, x1, y1, w1, h1)
			diagonal2(x, y, w1, 10, 255, 0, 0)
		end
	end

	cr:font_face('Arial', nil, 'bold')

	--desenam textul pentru remiza
	if game_status == 'draw' then
		local s = 'R3MIZA'
		cr:font_size(48)
		local ex, ey, ew, eh = text_extents(s)
		cr:rotate_around(x1 + w1 / 2, y1 + h1 / 2, -math.pi / 6)
		local x, y = center_rect(ew, eh, x1, y1, w1, h1)
		cr:move_to(x-ex, y-ey)
		cr:rgb(1, 0, 0)
		cr:show_text(s)
		cr:identity_matrix()
	end

	--desenam butonul de restart
	local x, y = 300, 100
	local s = 'R3START'
	cr:move_to(x, y)
	cr:font_size(36)
	local ex, ey, ew, eh = text_extents(s)
	local over_the_text = point_inside_rect(
		mouse_x, mouse_y,
		x + ex, y + ey, ew, eh)
	if game_status == 'continue' then
		cr:rgb(.3, .3, .3)
	else
		cr:rgb(1, 1, 1)
	end
	if over_the_text then
		if left_mouse_button_pressed then
			restart_game()
			cr:rgb(1, 0, 0)
		else
			cr:rgb(1, 1, 0)
		end
	end

	cr:show_text(s)

	--desenam tabela de scor
	cr:rgb(.7, .7, .7)
	cr:font_size(24)
	for i, player in ipairs{'X', '0'} do
		local score = score_table[player]
		local y = 140 + (i-1) * 28
		cr:move_to(300, y)
		cr:show_text(player..':')
		cr:move_to(350, y)
		cr:show_text(tostring(score_table[player]))
	end

	--desenam mouse-ul
	circle(mouse_x, mouse_y, 3, 3, 255, 255, 255)

	left_mouse_button_pressed = false
end

function win:mousemove(x, y)
	mouse_x, mouse_y = x, y
	self:invalidate()
end

function win:mousedown(button, x, y)
	mouse_x, mouse_y = x, y
	if button == 'left' then
		left_mouse_button_pressed = true
	end
	self:invalidate()
end

function win:mouseup(button, x, y)
	mouse_x, mouse_y = x, y
	if button == 'left' then
		left_mouse_button_pressed = false
	end
	self:invalidate()
end

app:run()

