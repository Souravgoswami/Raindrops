#!/usr/bin/ruby -W0
# Written by Sourav Goswami <souravgoswami@protonmail.com>
# GNU General Public License v3.0

require 'ruby2d'
$width, $height = 300, 400
set title: "Share", borderless: true, background: 'white', width: $width, height: $height

facebook = Image.new 'images/facebook.png'
facebook.x, facebook.y = $width/2 - facebook.width/2, 20

twitter = Image.new 'images/twitter.png'
twitter.x, twitter.y = $width/2 - twitter.width/2, facebook.y + facebook.height + 60

share = Image.new 'images/share.png'
share.x, share.y = $width/2 - share.width/2, twitter.y + twitter.height + 60

close_ = Image.new 'images/c.png', x: 5, y: 5, height: 15, width: 15

facebookhover, twitterhover, sharehover = false, false, false

on :mouse_move do |e|
	if facebook.contains?(e.x, e.y) then facebookhover = true else facebookhover = false end
	if twitter.contains?(e.x, e.y) then twitterhover = true else twitterhover = false end
	if share.contains?(e.x, e.y) then sharehover = true else sharehover = false end
	if close_.contains?(e.x, e.y)
		close_.color, close_.width, close_.height, close_.x, close_.y = 'teal', 17, 17, 4, 4
	else
		close_.color, close_.height, close_.width, close_.x, close_.y = 'white', 15, 15, 5, 5
	end
end

on :mouse_down do |e|
	if facebook.contains?(e.x, e.y)
		system('xdg-open', 'https://www.facebook.com/sharer/sharer.php?u=https://github.com/Souravgoswami/Raindrops')
		exit
	end

	if twitter.contains?(e.x, e.y)
		system('xdg-open', 'http://www.twitter.com/share?&text=Try Out this Simple Math Game! It\'s awesome and Free: &url=https://github.com/Souravgoswami/Raindrops&hashtags=RaindropsMath')
	end

	if share.contains?(e.x, e.y) then system('xdg-open', 'http://www.github.com/souravgoswami') ; exit end
	if close_.contains?(e.x, e.y) then close_.color = 'aqua' end
end

on :mouse_up do |e|
	exit if close_.contains?(e.x, e.y)
end

update do
	if facebookhover
		facebook.width += 1 if facebook.width < 80
		facebook.height += 1 if facebook.height < 80
		facebook.x, facebook.y = $width/2 - facebook.width/2, 20
	else
		facebook.width -= 2 if facebook.width > 70
		facebook.height -= 2 if facebook.height > 70
		facebook.x, facebook.y = $width/2 - facebook.width/2, 20
		facebook.color = 'white'
	end

	if twitterhover
		twitter.width += 1 if twitter.width < 80
		twitter.height += 1 if twitter.height < 80
		twitter.x, twitter.y = $width/2 - twitter.width/2, 160
	else
		twitter.width -= 2 if twitter.width > 70
		twitter.height -= 2 if twitter.height > 70
		twitter.x, twitter.y = $width/2 - twitter.width/2, 160
		twitter.color = 'white'
	end

	if sharehover
		share.width += 1 if share.width < 80
		share.height += 1 if share.height < 80
		share.x, share.y = $width/2 - share.width/2, 300
	else
		share.width -= 2 if share.width > 70
		share.height -= 2 if share.height > 70
		share.x, share.y = $width/2 - share.width/2, 300
		share.color = 'white'
	end
end

show
