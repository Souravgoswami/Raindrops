#!/usr/bin/ruby -W0
# Written by Sourav Goswami <souravgoswami@protonmail.com>
# GNU General Public License v3.0

require 'ruby2d'
$width, $height = 480, 480
set title: 'Stats Viewer', background: 'blue', width: $width, height: $height

def generate
	square = Square.new x: rand(50..$width), y: rand(0..$height + 500), size: rand(40..60) ; square.opacity = rand(0.1..0.3)
	square
end

downbuttons, upbuttons = {}, {}
for i in 0..5
	downbuttons.merge! i => Line.new(x1: 0, x2: $width/1.5, y1: $height - i * 35, y2: $height - i * 35, width:35, color: 'random', z: 0)
	upbuttons.merge! i => Line.new(x1: 0, x2: $width/1.5, y1: 0 + i * 35, y2: 0 + i * 35, width:35, color: 'random', z: 0)
end

down = Image.new 'images/down.png', x: $width/2 - 20, y: $height - 35, z: 1, width: 30, height: 30
up = Image.new 'images/up.png', x: $width/2 - 20, y: 5, width: 30, height: 30, z: 1
Rectangle.new width: $width, height: $height, color: %w(#60bfff #ff88dd #3ce3b4 #ffa3c4 )

quit_ = Rectangle.new width: 60, height: 20
quit_.x, quit_.y = $width - quit_.width - 5, $height - quit_.height - 5
quit__l = Text.new "Close", font: 'fonts/arima.otf', color: 'purple', x: quit_.x + 12, y: quit_.y - 2, size: 15

reset = Rectangle.new width: 60, height: 20
reset.x, reset.y = quit_.x - reset.width - 5, $height - reset.height - 5
reset_l = Text.new "Reset", font: 'fonts/arima.otf', color: 'purple', x: reset.x + 12, y: reset.y - 2, size: 15

column, texthash = 0, {}
$info = File.open('data/info.txt', 'r+')
$info.sync = true
data = $info.readlines

unless data.empty?
	data.each do |x|
		column += 1
		texthash.merge! column => Ruby2D::Text.new(x.chomp, font: 'fonts/arima.otf', x: 5, y: column * 20, size: 18, z: 1)
	end
else
	texthash.merge! 0 => Ruby2D::Text.new("No info right now!", font: 'fonts/arima.otf', x: 5, y: 0, size: 18, z: 1)
	texthash.merge! 1 => Ruby2D::Text.new("Perhaps Play the game for a while, and come back?", font: 'fonts/arima.otf', x: 5, y: 25, size: 18, z: 1)
end

particles = {}
10.times do |temp| particles.merge! temp => generate end

scrolldown, scrollup, scrollingup, scrollingdown, speed, speedvar = false, false, false, false, false, 0.5, 6

on :mouse_move do |e|
	downbuttons.each do |key, val|
		if val.contains?(e.x, e.y)
			scrolldown, scrollingdown = true, true
			speedvar = key
			break
		else
			scrolldown, scrollingdown, down.opacity = false, false, 1
		end
	end

	upbuttons.each do |key, val|
		if val.contains?(e.x, e.y)
			scrollup, scrollingup, speedvar = true, true, key
			break
		else
			scrollup, scrollingup, up.opacity = false, false, 1
		end
	end
	if reset.contains?(e.x, e.y) then reset.color, reset_l.color = 'purple', 'white' else reset.color, reset_l.color = 'white', 'purple' end
	if quit_.contains?(e.x, e.y) then quit_.color, quit__l.color = 'red', 'white' else quit_.color, quit__l.color = 'white', 'purple' end
end

on :mouse_up do |e|
	exit if quit_.contains?(e.x, e.y)
	if reset.contains?(e.x, e.y)
		if %x(ruby SubWindows/resetstatsconfirm.rb).include? 'RESET'
			$info.truncate(0)
		end

	end
end

on :mouse_scroll do |e|
	speedvar -= 0.5
	scrolldown, scrollup = true, false if e.delta_y == 1
	scrollup, scrolldown = true,false if e.delta_y == -1
end

update do
	sleep 0.001
	for particle in particles.values do
		particle.y -= 1 if particle.y > -particle.height
		particle.y = rand($height..$height + 500) if particle.y <= -particle.height
	end

	scrolldown, scrollup = false, false if Time.new.strftime('%N')[0].to_i  % 10 == 0 and (!scrollingdown and !scrollingup)
	if scrolldown
		down.opacity = 0.5
		speed = 1 if speedvar == 5
		speed = 5 if speedvar == 4
		speed = 10 if speedvar == 3
		speed = 13 if speedvar == 2
		speed = 15 if speedvar == 1
		speed = 20 if speedvar <= 0
		if texthash.values.last.y >= texthash.values.last.height + 400
			for val in texthash.values
				val.y -= speed
			end
		end
	else down.opacity = 1
	end

	if scrollup
		up.opacity = 0.5
		speed = 1 if speedvar == 5
		speed = 5 if speedvar == 4
		speed = 10 if speedvar == 3
		speed = 13 if speedvar == 2
		speed = 15 if speedvar == 1
		speed = 20 if speedvar == 0
		if texthash.values.first.y <= $height - texthash.values.first.height - 400 then for val in texthash.values do val.y += speed end end
	else up.opacity = 1
	end
end

show
