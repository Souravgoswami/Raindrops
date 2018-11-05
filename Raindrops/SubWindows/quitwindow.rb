#!/usr/bin/ruby -W0
# Written by Sourav Goswami <souravgoswami@protonmail.com>
# GNU General Public License v3.0

require 'ruby2d'
$width, $height = 280, 100
set title: "Confirm Quit", width: $width, height: $height, borderless: true, resizable: true, background: 'white'

confirmtext = Text.new ['Already Quit?', 'Quit Now?', 'Exit Game?', 'Quit Game?', 'Confirm Quit...'].sample, font: 'fonts/arima.otf',
		 x: 20, y: 20, color: 'purple', size: 20
button_colour, alt_button_colour = ['#58c4ff', '#00d5ac', '#01d5ac', '#54c5fd'], ['#f07da5', '#04d5a4', '#59c3ff', '#59c3ff']

yes = Rectangle.new x: confirmtext.x, y: confirmtext.y + confirmtext.height + 5, height: 30, width: 70, color: button_colour
yes_l = Text.new 'Yes', font: 'fonts/arima.otf', y: yes.y, color: 'white'
yes_l.x = yes.x + yes_l.width - 10

no = Rectangle.new x: yes.x + yes.width + 10, y: yes.y, height: 30, width: 70, color: button_colour
no_l = Text.new 'No', font: 'fonts/arima.otf', y: no.y, color: 'white'
no_l.x = no.x + no_l.width

yespressed, nopressed = false, false

close_ = Image.new 'images/c.png', x: 5, y: 5
closehover = false

on :mouse_move do |e|
	if close_.contains?(e.x, e.y) then close_.color, closehover = 'teal', true else close_.color, closehover = 'white', false end
	if confirmtext.contains?(e.x, e.y) then confirmtext.color = 'teal' else confirmtext.color = 'purple' end
	if yes.contains?(e.x, e.y) then yes.color, yes_l.color, yespressed = alt_button_colour, 'purple', true
		else yes.color, yes_l.color, yespressed = button_colour, 'white', false end
	if no.contains?(e.x, e.y) then no.color, no_l.color, nopressed = alt_button_colour, 'purple', true
		else no.color, no_l.color, nopressed = button_colour, 'white', false end
end

on :mouse_down do |e|
 	yes.color = 'teal' if yes.contains?(e.x, e.y)
	no.color = 'teal' if no.contains?(e.x, e.y)
	if close_.contains?(e.x, e.y) then close_.color = 'aqua' end
end

on :mouse_up do |e|
	nopressed, yespressed = false
	if yes.contains?(e.x, e.y) then puts 'QUIT' ; close end
	close if no.contains?(e.x, e.y)
	close if close_.contains?(e.x, e.y)
end

update do
	if yespressed
		yes.y -= 1 if yes.y > confirmtext.y + confirmtext.height
		yes_l.y -= 1 if yes_l.y > yes.y
	else
		yes.y += 1 if yes.y < confirmtext.y + confirmtext.height + 5
		yes_l.y += 1 if yes_l.y < yes.y
	end

	if nopressed
		no.y -= 1 if no.y > confirmtext.x + confirmtext.height
		no_l.y -= 1 if no_l.y > no.y
	else
		no.y += 1 if no.y < confirmtext.x + confirmtext.height + 5
		no_l.y += 1 if no_l.y < no.y
	end

	if closehover
		close_.width = 17
		close_.height = 17
		close_.x, close_.y = 4, 4
	else
		close_.width = 15
		close_.height = 15
		close_.x, close_.y = 5, 5
	end
end

show
puts 100
