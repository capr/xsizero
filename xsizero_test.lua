
local function test1()
	c(2, 2, 'X')
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
