#!/usr/bin/env ruby
require 'ruby2d'
set title: 'Choose Colour', background: 'white', width: 630, height: 165, resizable: true
choose = Text.new font: 'fonts/arima.otf', text: 'Choose!', z: 5 ; choose.opacity = 0
i, y, hashindex, colourhash, selected, v = 0.05, 0.08, 0, {}, false, ''

for colour in %w(#004da2 #088e34 #31302b #20099b #00b952 #2a8f00
				#41c7d0 #1d8583 #2a968e #030d0d #2f0d90 #170e36
				#00152f #172000 #0c918f #0d775a #1690ad #2e5915)
	if i  == 6.05 then y += 1 ; i = 0.05 end
	colourhash.merge! hashindex => Rectangle.new(x: i * 104, y: y * 54, width: 100, height: 50, color: colour)
	i += 1
	hashindex += 1
end

on :mouse_move do |e|
	for val in colourhash.values
		if val.contains?(e.x, e.y) then choose.x, choose.y, selected, v = val.x + 15, val.y + 10, true, val ; break
			else val.opacity, selected = 1, false end
	end
end
on :mouse_up do |e| for key in colourhash.keys do if colourhash[key].contains?(e.x, e.y) then puts key ; exit end end end
update do
	if selected
		choose.opacity += 0.1 if choose.opacity <= 1
		v.opacity -= 0.03 if v.opacity >= 0.5
		else choose.opacity -= 0.2 if choose.opacity >= 0 end
end
show
puts 100
exit
