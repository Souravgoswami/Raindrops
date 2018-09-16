#!/usr/bin/env ruby
require 'ruby2d'
$width, $height = 280, 100
set title: "New Game?", width: $width, height: $height, borderless: true, background: 'white'

warned = Text.new font: 'fonts/arima.otf', text: 'Warning! Start Refreshed?', x: 20, y: 20, color: 'red', size: 18
close_ = Image.new path: 'images/c.png', x: 5, y: 5, height: 15, width: 15

button_colour, alt_button_colour = ['#58c4ff', '#00d5ac', '#01d5ac', '#54c5fd'], ['#f07da5', '#04d5a4', '#59c3ff', '#59c3ff']

yes = Rectangle.new x: warned.x + warned.width/6, y: warned.y + warned.height + 5, height: 30, width: 70, color: button_colour
yes_l = Text.new font: 'fonts/arima.otf', text: %w(Yes Ok!).sample, y: yes.y, color: 'white'
yes_l.x = yes.x - yes_l.width + 50

no = Rectangle.new x: yes.x + yes.width + 10, y: warned.y + warned.height + 5, height: 30, width: 70, color: button_colour
no_l = Text.new font: 'fonts/arima.otf', text: %w(No! No).sample, y: no.y, color: 'white'
no_l.x = no.x - no_l.width + 50

yespressed, nopressed = false, false

on :mouse_move do |e|
	if yes.contains?(e.x, e.y) then yes.color, yes_l.color, yespressed = alt_button_colour, 'purple', true
		else yes.color, yes_l.color, yespressed = button_colour, 'white', false end

	if no.contains?(e.x, e.y) then no.color, no_l.color, nopressed = alt_button_colour, 'purple', true
		else no.color, no_l.color, nopressed = button_colour, 'white', false end

	if warned.contains?(e.x, e.y) then warned.color = 'purple' else warned.color = 'red' end
	if close_.contains?(e.x, e.y)
		close_.color = 'teal'
		close_.height, close_.width = 17, 17
		close_.x, close_.y = 4, 4
	else
		close_.color = 'white'
		close_.height, close_.width = 15, 15
		close_.x, close_.y = 5, 5
	end
end

on :mouse_down do |e|
 	yes.color = 'red' if yes.contains?(e.x, e.y)
	no.color = 'green' if no.contains?(e.x, e.y)
	close_.color = 'aqua' if close_.contains?(e.x, e.y)
end

on :mouse_up do |e|
	nopressed, yespressed = false
	if yes.contains?(e.x, e.y) then puts 'NEWGAME' ; exit end
	exit if no.contains?(e.x, e.y) or close_.contains?(e.x, e.y)
end

update do
	if yespressed
		yes.y -= 1 if yes.y > warned.y + warned.height
		yes_l.y -= 1 if yes_l.y > yes.y
	else
		yes.y += 1 if yes.y < warned.y + warned.height + 5
		yes_l.y += 1 if yes_l.y < yes.y
	end

	if nopressed
		no.y -= 1 if no.y > warned.y + warned.height
		no_l.y -= 1 if no_l.y > no.y
	else
		no.y += 1 if no.y < warned.y + warned.height + 5
		no_l.y += 1 if no_l.y < no.y
	end
end

show
puts 100
