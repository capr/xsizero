
--X si Zero (The Game!!!)
--Autori: Ioana Popa & Cosmin Apreutesei. Public Domain.

a = {
	{' ', ' ', ' '},
	{' ', ' ', ' '},
	{' ', ' ', ' '},
}

function play_round(x, y, symbol) --'X', '0'
	if a[y][x] ~= ' ' then
		error'nu se poate'
	end
	a[y][x] = symbol
end

function f(symbol)

	--return symbol == ' ' and '_' or symbol

	if symbol == ' ' then
		return '_'
	else
		return symbol
	end
end

function show_board()
	for y=1,3 do
		print(f(a[y][1]), f(a[y][2]), f(a[y][3]))
	end
end

function check_status()

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

function test1()
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

--test1()
