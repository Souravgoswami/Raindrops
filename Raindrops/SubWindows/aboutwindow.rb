#!/usr/bin/env ruby
require 'ruby2d'
$width, $height = 900, 600
set title: "About Raindrops", background: 'blue', width: $width, height: $height

def generate ; s = Square.new x: rand(0..$width), y: rand(500..$height + 500), size: rand(80..100), color: 'white', z: -1 ; s.opacity = rand(0.2..0.4) ; s end

yval = 0.1
File.open('data/about.info').readlines.each do |x| Text.new text: x.chomp, x: 5, y: yval * 20, color: 'white', font: 'fonts/arima.otf', size: 16 ; yval += 1 end

Rectangle.new width: $width, height: $height, color: %w(#ff50a6 blue #00e3d5 #3ce3d4), z: -5

share = Text.new font: 'fonts/arima.otf', text: 'Share!', color: 'blue', size: 18
share.x, share.y = $width - share.width - 70, $height - share.height + 5
share_line = false

quit_ = Text.new font: 'fonts/arima.otf', text: 'Close', color: 'blue', size: 18
quit_.x, quit_.y = share.x + share.width + 20, share.y

credit = Text.new text: "Credits: ", font: "fonts/arima.otf", size: 15, x: 5, y: $height - 22
author = Text.new text: "Sourav Goswami. ", font: "fonts/arima.otf", size: 15, x: credit.x + credit.width, y: $height - 22
thanks = Text.new text: "Special thanks to ", font: "fonts/arima.otf", size: 15, x: author.x + author.width, y: $height - 22
ruby2d_ = Text.new text: "Ruby2D.", font: "fonts/arima.otf", size: 15, x: thanks.x + thanks.width, y: $height - 22

authorline = Line.new x1: author.x + author.width/2, x2: author.x + author.width/2, y1: author.y + author.height - 6, y2: author.y + author.height - 6
ruby2dline = Line.new x1: ruby2d_.x + ruby2d_.width/2, x2: ruby2d_.x + ruby2d_.width/2, y1: ruby2d_.y + ruby2d_.height - 6, y2: ruby2d_.y + ruby2d_.height - 6
quitline = Line.new x1: quit_.x + quit_.width/2, x2: quit_.x + quit_.width/2, y1: quit_.y + quit_.height - 6, y2: quit_.y + quit_.height - 6
shareline = Line.new x1: share.x + share.width/2, x2: share.x + share.width/2, y1: share.y + share.height - 6, y2: share.y + share.height - 6

author_line, ruby2d_line = false, false
quit_line, share_line = false, false

on :mouse_move do |e|
	if author.contains?(e.x, e.y) then author.color = '#008080' ; author_line = true else author.color = 'white' ; author_line = false end
	if ruby2d_.contains?(e.x, e.y) then ruby2d_.color = '#ff7a94' ; ruby2d_line = true else ruby2d_.color = 'white' ; ruby2d_line = false end
	if share.contains?(e.x, e.y) then share.color = 'purple' ; share_line = true else share.color = 'blue' ; share_line = false end
	if quit_.contains?(e.x, e.y) then quit_.color = 'purple' ; quit_line = true else quit_.color = 'blue' ; quit_line = false end
end

on :mouse_down do |e|
	if author.contains?(e.x, e.y) then author.color = '#004040' ; else author.color = 'white' end
	if ruby2d_.contains?(e.x, e.y) then ruby2d_.color = 'red' ; else ruby2d_.color = 'white' end
end

on :mouse_down do |e|
	system('ruby SubWindows/share.rb') if share.contains?(e.x, e.y)
	exit if quit_.contains?(e.x, e.y)
end

on :mouse_up do |e|
	system('xdg-open', 'https://github.com/Souravgoswami') if author.contains?(e.x, e.y)
	system('xdg-open', 'http://www.ruby2d.com') if ruby2d_.contains?(e.x, e.y)
	close if quit_.contains?(e.x, e.y)
end

squares, i = {}, 0
5.times do |temp| squares.merge! temp => generate end

update do
	i += 1
	squares.values.each do |val|
		val.y -= 1
		val.opacity, val.y = rand(0.1..0.5), rand($height..$height + 1000) if val.opacity <= 0 or val.y <= 0 - val.height
	end

	if author_line
		authorline.x1 -= 3 if authorline.x1 >= author.x
		authorline.x2 += 3 if authorline.x2 <= author.x + author.width
		author.y -= 1 if author.y > credit.y - 3
	else
		authorline.x1 += 3 if authorline.x1 < author.x + author.width/2
		authorline.x2 -= 3 if authorline.x2 > author.x + author.width/2
		author.y += 0.5 if author.y < credit.y
	end

	if ruby2d_line
		ruby2dline.x1 -= 2 if ruby2dline.x1 >= ruby2d_.x
		ruby2dline.x2 += 2 if ruby2dline.x2 <= ruby2d_.x + ruby2d_.width
		ruby2d_.y -= 0.5 if ruby2d_.y > credit.y - 3
	else
		ruby2dline.x1 += 2 if ruby2dline.x1 < ruby2d_.x + ruby2d_.width/2
		ruby2dline.x2 -= 2 if ruby2dline.x2 > ruby2d_.x + ruby2d_.width/2
		ruby2d_.y += 1 if ruby2d_.y < credit.y
	end

	if quit_line
		quitline.x1 -= 2 if quitline.x1 > quit_.x
		quitline.x2 += 2 if quitline.x2 < quit_.x + quit_.width
		quitline.y1 = quitline.y2 = quit_.y + quit_.height - 8
		quit_.y -= 0.5 if quit_.y > credit.y - 10
	else
		quitline.x1 += 2 if quitline.x1 < quit_.x + quit_.width/2
		quitline.x2 -= 2 if quitline.x2 > quit_.x + quit_.width/2
		quitline.y1 = quitline.y2 = quit_.y + quit_.height - 8
		quit_.y += 1 if quit_.y < credit.y - 5
	end

	if share_line
		shareline.x1 -= 2 if shareline.x1 > share.x
		shareline.x2 += 2 if shareline.x2 < share.x + share.width
		shareline.y1 = shareline.y2 = share.y + share.height - 8
		share.y -= 0.5 if share.y > credit.y - 10
	else
		shareline.x1 += 2 if shareline.x1 <  share.x + share.width/2
		shareline.x2 -= 2 if shareline.x2 > share.x + share.width/2
		shareline.y1 = shareline.y2 = share.y + share.height - 8
		share.y += 1 if share.y < credit.y - 5
	end
end

show
