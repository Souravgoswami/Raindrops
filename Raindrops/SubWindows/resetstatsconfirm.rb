#!/usr/bin/env ruby
# Written by Sourav Goswami <souravgoswami@protonmail.com>
# GNU General Public License v3.0

require 'ruby2d'
$width, $height = 350, 100
set title: "Reset Stats?", width: $width, height: $height, resizable: true, borderless: true, background: '#5978fa'

warning_text = Text.new 'Warning! Are you Sure to Reset Your Data?', font: 'fonts/arima.otf', x: 30, y: 20, color: 'white', size: 15

button_colour, alt_button_colour = ['#58c4ff', '#00d5ac', '#01d5ac', '#54c5fd'], ['#f07da5', '#04d5a4', '#59c3ff', '#59c3ff']

yes = Rectangle.new x: warning_text.x + warning_text.width/4, y: warning_text.y + warning_text.height + 5, height: 30, width: 70, color: button_colour
yes_l = Text.new %w(Yes Ok!).sample, font: 'fonts/arima.otf', y: yes.y, color: 'white'
yes_l.x = yes.x - yes_l.width + 50

no = Rectangle.new x: yes.x + yes.width + 10, y: warning_text.y + warning_text.height + 5, height: 30, width: 70, color: button_colour
no_l = Text.new %w(No! No).sample, font: 'fonts/arima.otf', y: no.y, color: 'white'
no_l.x = no.x - no_l.width + 50

close_ = Image.new 'images/c.png', x: 5, y: 5

yespressed, nopressed = false, false

on :mouse_move do |e|
	if yes.contains?(e.x, e.y)
		yes.color = alt_button_colour
		yes_l.color ='yellow'
		yespressed = true
	else
		yes.color = button_colour
		yes_l.color = 'white'
		yespressed = false
	end

	if no.contains?(e.x, e.y)
		no.color = alt_button_colour
		no_l.color = 'yellow'
		nopressed = true
	else
		no.color = button_colour
		no_l.color = 'white'
		nopressed = false
	end

	if warning_text.contains?(e.x, e.y) then warning_text.color = 'yellow' else warning_text.color = 'white' end

	if close_.contains?(e.x, e.y) then close_.color = 'teal' else close_.color = 'white' end
end

on :mouse_down do |e|
 	yes.color = 'red' if yes.contains?(e.x, e.y)
	no.color = 'green' if no.contains?(e.x, e.y)
	close_.color = 'aqua' if close_.contains?(e.x, e.y)
end

on :mouse_up do |e|
	nopressed, yespressed = false
	if yes.contains?(e.x, e.y) then puts 'RESET' ; exit end
	exit if no.contains?(e.x, e.y) or close_.contains?(e.x, e.y)
end

update do
	yes.opacity -= 0.005 if yespressed and yes.opacity >= 0.1
	no.opacity -= 0.005 if nopressed and no.opacity >= 0.1
end

show
puts 100
