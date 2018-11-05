#!/usr/bin/env ruby
begin
	require 'ruby2d'
rescue LoadError => e
	warn "\033[38;5;171m#{e}\033[0m\n\n"
	warn "Description:\n"
	warn "\tRuby2D is not found in the default directory."
	warn "\tRuby2D is Required by the scripts and the subscripts."
	warn "Exiting"
	exit! 127
end

$info = File.open('data/info.txt', 'a+')
$info.sync = true

class MagicParticles
	def initialize(hash) @hash = hash end

	def self.generate(x, y, magic=true, mouse=false, smoke=false)
		if magic then square = Square.new x: x, y: y, z: 0, color: %w(yellow white #f5ffa3 blue #ff50a6).sample, size: rand(1..2)
		elsif mouse
			square = Image.new( "images/#{['hoverstars.png', 'hoverstars1.png'].sample}") ; square.width = square.height = rand(10..12)
		elsif smoke then square = Square.new x: x, y: y, z: -1, color: 'yellow', size: rand(1..2) ; square.opacity = 0
		else square = Square.new x: x, y: y, z: 0, color: 'white', size: rand(8..12) ; square.opacity = 0 end ; square
	end

	def items() @hash.keys.each do |key| yield @hash[key] if block_given? end end

	def float(fizzing=false, magic=false, lowerlimit=50, upperlimit=200, x, y)
		for key in @hash.keys
			if @hash[key].y >= y
				@hash[key].y -= rand(1..8) unless fizzing
				@hash[key].y -= 1 if fizzing
				@hash[key].size, @hash[key].color = rand(0..2), 'yellow' if fizzing
				@hash[key].x += [-1, -2, -3, 0, 1, 2, 3].sample
				@hash[key].z = 1 if fizzing
				@hash[key].opacity -= rand(0.05..0.1) if @hash[key].opacity >= 0 and magic
				@hash[key].opacity -= rand(0.005..0.01) if @hash[key].opacity >= 0 and !magic
			elsif
				@hash[key].y += rand(lowerlimit..upperlimit)
				@hash[key].x = x
				@hash[key].opacity = 1 if magic
			end
		end
	end
	def alpha=(value=[0, 0.1, 0.4, 0.6, 0.8, 1].sample) for key in @hash.keys do @hash[key].opacity = value end end
	def pos(x, y) for key in @hash.keys do obj = @hash[key] ; obj.x, obj.y = x, y end end
	def draw(initialized=false)
			for key in @hash.keys do
			obj = @hash[key]
			obj.x -= [-1, 0, 1].sample
			obj.y += [2, 0].sample if initialized
			obj.y -= [2, 0].sample unless initialized
			obj.opacity -= 0.015 if obj.opacity >= 0
		end
	end
	def shuffle(x, y)
		obj = @hash.values.sample
		obj.x, obj.y = x, y
		obj.opacity = 1
	end
end

def main
	generate = ->(level=1) do
		case level
			when 1
				text = ["#{rand(0..10)}#{[:+].sample}#{rand(1..10)}", "#{rand(10..20)}#{[:-].sample}#{rand(0..9)}"].sample
			when 2
				text = "#{rand(0..10)}#{[:+, :-, :*].sample}#{rand(1..10)}"
			when 3
				n = rand(1..5)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(1..10)}", "#{(n..100).step(n).to_a.sample}/#{n}"].sample
			when 4
				n = rand(1..8)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(10..20)}", "#{rand(-10..50)}#{[:+].sample}#{rand(0..50)}",
					"#{(n..50).step(n).to_a.sample}/#{n}"].sample
			when 5
				n = rand(2..8)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(10..20)}", "#{(n..120).step(n).to_a.sample}/#{[[n/2.0, n].sample].sample}"].sample
			when 6
				n = rand(4..10)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(-10..20)}", "#{(5..100).step(5).to_a.sample}/#{[1, 2.5, 5].sample}",
					"#{rand(-50..200)}#{[:+, :-].sample}#{rand(-100..250)}", "#{rand(-10..20)}#{[:*].sample}#{rand(0..20)}",
					"#{(n..120).step(n).to_a.sample}/#{[n/4.0, n/2.0, n].sample}"].sample
			when 7
				n = rand(5..12)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(-10..20)}", "#{(n..100).step(n).to_a.sample}/#{[n/8.0, n/4.0, n/2.0, n].sample}"].sample
			when 8
				n = rand(8..20)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(-10..20)}", "#{(n..200).step(n).to_a.sample}/#{[n/8.0, n/4.0, n/2.0, n].sample}"].sample
			when 9
				n = rand(12..50)
				text = ["#{rand(-10..20)}#{[:+, :-, :*].sample}#{rand(-10..20)}", "#{(n..200).step(n).to_a.sample}/#{[n/16.0, n/8.0, n/4.0, n/2.0, n].sample}"].sample
		end
		x, y = rand(20..$width - 60), rand(-50..10)
		t = Text.new text, x: x, y: y, font: 'fonts/arima.otf', size: 18, z: rand(0..2) ; t.opacity = 0 ; t
	end
		colour_of_the_day = %w(blue teal green lime yellow orange red fuchsia purple #3ce3b4 #ff50a6).sample
		keycolour = %w(blue teal green lime yellow orange red fuchsia purple #3ce3b4 #ff50a6 gray #ada9ff #fda6ff #fd8bb7)
		$width, $height = 1200, 900
		img = {}
		set title: "RainDrops", background: 'black', width: $width, height: $height, resizable: true
		obj, h, i, t = 0, {}, 0, Proc.new { |format| Time.new.strftime(format) }
		bg = Image.new( 'images/bg1.png', z: -10)
		time, pressed_key = t.call('%s'), ''
		notificationline = Line.new x1: 0, y1: 20, x2: $width, y2: 20, width: 40, color: 'black', z: 5
		notificationline.opacity, notificationline.y1 = 0.5, notificationline.y2 = notificationline.width/2
		notificationtime = Text.new t.call('%T'), x: notificationline.x2/2, y: 5, font: 'fonts/arima.otf', z: 5
		notificationtime.x = $width/2 - notificationtime.width/2
		timeline = Line.new x1: notificationtime.x + notificationtime.width/2, x2: notificationtime.x + notificationtime.width/2,
					y1: notificationtime.y + notificationtime.height - 5, y2: notificationtime.y + notificationtime.height - 5,
					z: 5, color: colour_of_the_day
		timehover= false

		restriction, inittime, score, high_score, level, old_level, force_level, speed = 0, '', 0, 0, 1, 1, false, 0.7
		lives, answered, missed = 9, 0, 0

		menu_box = Rectangle.new y: 40, width: 0, height: $height - 300, color: ['white', 'black'].sample, z: 5 ; menu_box.opacity = 0.2
		menu_text = Text.new "Menu", y: menu_box.y + 0, font: 'fonts/arima.otf', color: 'white', size: 28, z: 5
		menu_text.x, menu_text.opacity = menu_box.width/2 - menu_text.width, 1

		level_details = {1 => :VeryEasy, 2 => :Easy, 3 => :Medium, 4 => :Hard, 5 => :ExremelyHard, 6 => :UltraHard, 7 => :HumanCalculator, 8 => :ExtremeHumanCalculator}

		score_l = Text.new "Score: 5000    Highest Score: 1000", y: 5, font: 'fonts/arima.otf', z: 5, size: 13
		score_l.x = notificationline.x2 - score_l.width - 10

		lives_l = Text.new "Level: 9    Lives: 1000", y:  score_l.y + score_l.height - 5, font: 'fonts/arima.otf', z: 5, size: 13
		lives_l.x = score_l.x + score_l.width/2 - lives_l.width/2

		show_menu = Image.new  'images/menu.png', x: 5, y: 2, height: 35, width: 35, z: 5

		triggered, started, spacetrig = false, false, 0

		back_button = Image.new  'images/back.png', x: 5, y: menu_text.y + 10
		back_button.x = -back_button.width + 15

		flakehash, bird_spritesheet = [], []

		Image.new  'images/tree1.png', y: $height - 40
		Image.new  'images/tree1.png', x: 20, y: $height - 40
		Image.new  'images/tree1.png', x: 50, y: $height - 40
		Image.new  'images/tree1.png', x: 90, y: $height - 40
		Image.new  'images/tree1.png', x: 110, y: $height - 40
		Image.new  'images/tree6.png', x: 30, y: $height - 30
		Image.new  'images/tree2.png', x: 5, y: $height - 100
		Image.new  'images/tree3.png', x: 50, y: $height - 100
		Image.new  'images/tree4.png', x: 80, y: $height - 40
		Image.new  'images/tree5.png', x: 100, y: $height - 90
		Image.new  'images/tree6.png', x: 145, y: $height - 30
		Image.new  'images/flowerbush.png', x: 105, y: $height - 30

		cloud1 = Image.new  'images/cloud1.png', x: $width, y: rand(0..400) ; cloud1.opacity = 0.3
		cloud2 = Image.new  'images/cloud2.png', x: $width, y: rand(20..400) ; cloud2.opacity = 0.3
		cloud3 = Image.new  'images/cloud3.png', x: $width, y: rand(0..400) ; cloud3.opacity = 0.3
		cloud4 = Image.new  'images/cloud4.png', x: $width, y: rand(0..400) ; cloud4.opacity = 0.3
		colourcloud = Image.new  'images/colourcloud.png', x: rand(0..$width), y: 100 ; colourcloud.opacity = 0.6
		colourcloudswitch = [true, false].sample
		cloud = rand(1..4)

		button_colour, alt_button_colour = ['#58c4ff', '#00d5ac', '#01d5ac', '#54c5fd'], ['#f07da5', '#04d5a4', '#59c3ff', '#59c3ff']
		play = Rectangle.new y: menu_box.y + 50, width: 230, height: 40, z: 5 ; play.x, play.opacity = -play.width + 15, 0
		newgame = Rectangle.new y: menu_box.y + 100, width: 230, height: 40, z: 5, color: button_colour ; newgame.x, newgame.opacity = -newgame.width + 15, 0
		background = Rectangle.new y: menu_box.y + 150, width: 230, height: 40, z: 5, color: button_colour ; background.x, background.opacity = -background.width + 15, 0
		level_plus =  Rectangle.new x: menu_box.x + 15, y: menu_box.y + 200, width: 110, height: 40, z: 5, color: button_colour ; level_plus.x, level_plus.opacity = -level_plus.width + 15, 0
		level_minus = Rectangle.new y: menu_box.y + 200, width: 110, height: 40, z: 5, color: button_colour ; level_minus.x, level_minus.opacity = -level_plus.width + 25, 0
		stats =  Rectangle.new y: menu_box.y + 250, width: 110, height: 40, z: 5, color: button_colour ; stats.x, stats.opacity = -stats.width + 15, 0
		reset_stats = Rectangle.new y: menu_box.y + 250, width: 110, height: 40, z: 5, color: button_colour ; reset_stats.x, reset_stats.opacity = -level_plus.width + 25, 0
		about = Rectangle.new x: menu_box.x + 15, y: menu_box.y + 300, width: 230, height: 40, z: 5, color: button_colour ; about.x, about.opacity = -about.width + 15, 0
		quit_ = Rectangle.new x: menu_box.x + 15, y: menu_box.y + 350, width: 230, height: 40, z: 5, color: button_colour ; quit_.x, quit_.opacity = -quit_.width + 15, 0

		menuscorebox = Image.new  'images/box230x80.png', x: menu_box.x + 15, y: quit_.y + quit_.height + 15 ; menuscorebox.opacity = 0

		score_menu = Text.new "Score: 900000", y: quit_.y + quit_.height + 20, font: 'fonts/arima.otf', z: 5, size: 18
		score_menu.x, score_menu.opacity = menu_box.x + 25, 0

		highestscore_menu = Text.new "Highest: 9000000", y: quit_.y + quit_.height + 40, font: 'fonts/arima.otf', z: 5, size: 18
		highestscore_menu.x, highestscore_menu.opacity = menu_box.x + 25, 0

		lives_menu = Text.new "Level: 9    Lives: 1000", y: quit_.y + quit_.height + 60, font: 'fonts/arima.otf', z: 5, size: 18
		lives_menu.x, lives_menu.opacity = menu_box.x + 25, 0

		answered_menu = Image.new  'images/box230x60.png', x: menu_box.x + 15, y: menuscorebox.y + menuscorebox.height + 5 ; answered_menu.opacity = 0

		answered_l =Text.new "Answered: 0", y: answered_menu.y + 5, font: 'fonts/arima.otf', z: 5, size: 18
		answered_l.x, answered_l.opacity = menu_box.x + 25, 0

		missed_l =Text.new "Missed: 0", y: answered_l.y + answered_l.height - 10, font: 'fonts/arima.otf', z: 5, size: 18
		missed_l.x, missed_l.opacity = menu_box.x + 25, 0

		key_layout = Rectangle.new y: $height - 280, width: 270, height: 230, color: 'black', z: 0
		key_layout.x = $width - key_layout.width * 1.8
		key_layout.opacity = 0.3
		inittext = Text.new "Press Enter to Start", font: 'fonts/DancingScript-Bold.ttf', size: 120, z: -1
		inittext.x, inittext.y = inittext.width/2 - $width/4, $width/2 - inittext.height * 2

		liveboost = Image.new  'images/life.png'
		liveboost.opacity = 0

		livereduce = Image.new  'images/lifeminus.png'
		livereduce.opacity = 1

		water = Line.new x1: 0, x2: $width, y1: $height, y2: $height, color: 'blue', width: 40, z: -1 ; water.opacity = 0.5
		boat, boattrigger = Image.new( 'images/boat.png', width: 60, height: 60, z: -2), false
		boatglow = Image.new( 'images/boatglow.png', width: 60, height: 60, z: -3) ; boatglow.opacity = 0

		magehash, particleshash, treeparticleshash, hoverparticleshash, glowparticleshash, smokehash, bubblehash = {}, {}, {}, {}, {}, {}, {}
		for temp in 0..15
			magehash.merge! temp => MagicParticles.generate(rand(key_layout.x..key_layout.x + key_layout.width),key_layout.y + key_layout.height)
			hoverparticleshash.merge! temp => MagicParticles.generate(50, 50, false, mouse=true)
			glowparticleshash.merge! temp => MagicParticles.generate(50, 50)
			smokehash.merge! temp => MagicParticles.generate(500, 500, false, true, true)
			bubblehash.merge! temp => MagicParticles.generate(rand(0..250), rand($height - 200..$height), true)
		end

		for temp in 0..10
			particleshash.merge! temp => MagicParticles.generate(rand(0..$width), rand($height - 400..$height), false)
			treeparticleshash.merge! temp => MagicParticles.generate(rand(0..250), rand($height - 200..$height))
		end

		magicparticles = MagicParticles.new(magehash)
		particles = MagicParticles.new(particleshash)
		treeparticles = MagicParticles.new(treeparticleshash)
		hoverparticles = MagicParticles.new(hoverparticleshash)
		glowparticles = MagicParticles.new(glowparticleshash)
		smokes = MagicParticles.new(smokehash)
		magicice = MagicParticles.new(bubblehash)

		crystal_bank, rand_white_crystal_y= [], rand(35..45)

		0.step(240, 20) do |temp| crystal_bank << Image.new( 'images/crystal.png', x: key_layout.x + temp, y: key_layout.y + key_layout.height - 35) end
		6.times do |temp| crystal_bank << Image.new( 'images/crystal2.png', x: key_layout.x + temp * rand_white_crystal_y , y: key_layout.y + key_layout.height - 25, color: colour_of_the_day) end

		key_layoutline1 = Line.new x1: key_layout.x, x2: key_layout.x + key_layout.width, y1: key_layout.y, y2: key_layout.y,color: 'white', z: 1
		key_layoutline2 = Line.new x1: key_layout.x, x2: key_layout.x + key_layout.width, y1: key_layout.y + key_layout.height, y2: key_layout.y + key_layout.height, color: 'white', z: 1
		key_layoutline3 = Line.new x1: key_layout.x, x2: key_layout.x, y1: key_layout.y, y2: key_layout.y + key_layout.height, z: 1
		key_layoutline4 = Line.new x1: key_layout.x + key_layout.width, x2: key_layout.x + key_layout.width,  y1: key_layout.y, y2: key_layout.y + key_layout.height, z: 1

		flake1 = Image.new( 'images/flake1.png', x: rand(key_layoutline2.x1..key_layoutline2.x2), y: rand(key_layoutline2.y1 - 20..key_layoutline2.y1))
		flake1.opacity = 0
		flake2 = Image.new( 'images/flake2.png', x: rand(key_layoutline2.x1..key_layoutline2.x2), y: rand(key_layoutline2.y1 - 20..key_layoutline2.y1))
		flake2.opacity = 0

		display = Rectangle.new x: key_layout.x + 10, y: key_layout.y + 10, width: key_layout.width - 20, height: 50 ; display.opacity = 0.5
		display_l = Text.new y: display.y + 5, font: 'fonts/arima.otf', size: 25
		display_l.x = display.x + display.width - display_l.width - 10

		display_c_l = Image.new  'images/c.png', x: display.x + display.width - 23, y: display.y + 15

		nums, nums_l, y, num = {}, {}, 10, 0
		4.times do 0.step(130, 65) do |temp|
				num += 1
				nums.merge! num => Rectangle.new(x: display.x + temp, y: display.y + display.height + y, height: 30, width: 50, color: keycolour.rotate[num])
				nums_l.merge! num => Text.new(num, x: display.x + temp + 20, y: display.y + display.height + y, font: 'fonts/arima.otf', color: 'white') if num <= 9
			end
			y += 40
		end

		rot = Text.new 'R', x: display.x + 20, y: display.y + display.height + y - 40 , font: 'fonts/arima.otf', color: 'white', z: 1
		n0 =  Text.new 0, x: display.x + 25 + 60, y: display.y + display.height + y - 40, font: 'fonts/arima.otf', color: 'white', z: 1
		del =  Text.new 'X', x: display.x + 30 + 120, y: display.y + display.height + y - 40, font: 'fonts/arima.otf', color: 'white', z: 1

		nums.merge! 13 => Rectangle.new(x: display.x + 195, y: display.y + display.height + 10, height: 30, width: 50, color: keycolour.rotate[num + 1])
		minus_l = Text.new '-', x: display.x + 25 + 190, y: display.y + display.height + 10, font: 'fonts/arima.otf', color: 'white', z: 1

		nums.merge! 14 => Rectangle.new(x: display.x + 195, y: display.y + display.height + 50, height: 30, width: 50, color: keycolour.rotate[num + 2])
		pause = Text.new 'P', x: display.x + 25 + 190, y: display.y + display.height + 50, font: 'fonts/arima.otf', color: 'white', z: 1

		move_l = Image.new  'images/move.png', x: display.x + 190, y: display.y + display.height + 100

		play_l = Text.new 'Play', y: play.y + 4, font: 'fonts/arima.otf', z: 5
		play_l.x, play_l.opacity = play.width/2 - 30, 0

		newgame_l = Text.new 'New Game', y: newgame.y + 4, font: 'fonts/arima.otf', z: 5
		newgame_l.x, newgame_l.opacity = newgame.width/2 - 30, 0

		background_l = Text.new 'Background', y: background.y + 4, font: 'fonts/arima.otf', z: 5
		background_l.x, background_l.opacity =background.width/2 - 35, 0

		level_plus_l = Text.new 'Level +', y: level_plus.y + 4, font: 'fonts/arima.otf', z: 5
		level_plus_l.x, level_plus_l.opacity = level_plus.width/2 - 15, 0

		level_minus_l = Text.new 'Level -', y: level_minus.y + 4, font: 'fonts/arima.otf', z: 5
		level_minus_l.x, level_minus_l.opacity = level_minus.width + level_minus.x - level_minus_l.width - 25, 0

		stats_l = Text.new 'Stats', y: stats.y + 4, font: 'fonts/arima.otf', z: 5
		stats_l.x, stats_l.opacity =stats.width/2 - 15, 0

		reset_stats_l = Text.new 'Reset', y: reset_stats.y + 4, font: 'fonts/arima.otf', z: 5
		reset_stats_l.x, reset_stats_l.opacity = reset_stats.width + reset_stats.x - reset_stats_l.width - 30, 0

		about_l = Text.new 'About', y: about.y + 4, font: 'fonts/arima.otf', z: 5
		about_l.x, about_l.opacity = about.width/2 -15, 0

		quit__l = Text.new 'Quit', y: quit_.y+ 4, font: 'fonts/arima.otf', z: 5
		quit__l.x, quit__l.opacity = quit_.width/2 - 5, 0

		tada = Sound.new 'sounds/tada.mp3'
		robot_blip = Sound.new 'sounds/pling.mp3'
		keypress_sound = Sound.new 'sounds/k1.mp3'
		sizzling = Sound.new 'sounds/sizzling.mp3'
		music = Music.new 'sounds/Patakas World.wav'
		buttonpush = Sound.new 'sounds/buttonpush.mp3'
		plop = Sound.new 'sounds/plop.mp3'
		waternoise = Sound.new 'sounds/waternoise.mp3'
		music.loop = true

		$info.puts("Game Started #{t.call('on %D at %T')}")
		on :key_down do |k|
			if k.key == 'r'
				keycolour.rotate!
				nums.keys.each do |key| nums[key].color = keycolour.rotate[key] end
			end
			bg.color = 'random' if k.key == 'b'

			if ['return', 'keypad enter'].include?(k.key) and !started
				Sound.new('sounds/k2.mp3').play
				glowparticles.alpha = 1
				started = true
				tada.play
				started, triggered, pressed_key, inittime, lives, restriction, speed = true, false, '', t.call('%s'), 9, 0, 0.7
				$info.puts("    New Game at: #{t.call('%T')}")
			else
				if k.key.scan(/[0-9]/)[0] and pressed_key.length <= 11
					keypress_sound.play
					pressed_key += k.key.scan(/[0-9]/)[0]
					for temp in nums.keys do
						if temp == k.key.scan(/[1-9]/)[0].to_i
							nums[temp].color = 'blue'
						elsif k.key.include?('0')
						 	nums[11].color = 'blue'
						end
					end
				elsif k.key.include?('-') and !pressed_key.include?('-')
					pressed_key += '-'
					nums[13].color = 'blue'
					keypress_sound.play
				end
				if ['backspace', 'x'].include?(k.key)
					pressed_key.chop!
					del.color = 'red'
				end
				if ['delete', 'c'].include?(k.key)
					pressed_key = ''
					display_c_l.color = 'blue'
				end
			end

			if k.key.match(/^space+$|^escape+$|^q+$|^p+$/)
				spacetrig += 1
				if spacetrig % 2 == 1
					show_menu.color = colour_of_the_day
					triggered = true
					play.color = newgame.color = background.color = level_plus.color = level_minus.color = stats.color = reset_stats.color = about.color = quit_.color = ['#58c4ff', '#00d5ac', '#01d5ac', '#54c5fd']
					else triggered, show_menu.color = false, 'white' end
			end
		end

		on :key_up do |k|
			for temp in nums.keys do nums[temp].color = keycolour.rotate[temp] if temp == k.key.scan(/[1-9]/)[0].to_i end

			del.color = 'white' if k.key == 'backspace' or k.key == 'x'
			nums[11].color = colour_of_the_day if k.key.include?('0')
			if k.key == 'delete' or k.key == 'c'
				display_c_l.color = 'white'
			end
		end
		keypadmove = false
		on :mouse_move do |e|
			hoverparticles.shuffle(rand(e.x - 5..e.x + 10), rand(e.y..e.y + 20))
			if notificationline.contains?(e.x, e.y) then notificationline.opacity = 1 end
			if water.contains?(e.x, e.y) then water.color, water.opacity = '#0084f7', 0.5
				else water.color, water.opacity = 'blue', 0.5
			end

			for val in flakehash do val.opacity -= 0.05 if val.contains?(e.x, e.y) and val.y >= notificationline.y2 end
			if show_menu.contains?(e.x, e.y) then show_menu.color = colour_of_the_day
				else show_menu.color = 'white' end
			if notificationtime.contains?(e.x, e.y)
				notificationtime.color = timeline.color = colour_of_the_day
				timehover = true
				else
				notificationtime.color = timeline.color = 'white'
				timehover = false
			end
			if score_l.contains?(e.x, e.y) then score_l.color = colour_of_the_day
				else score_l.color = 'white' end
			if lives_l.contains?(e.x, e.y) then lives_l.color = colour_of_the_day
				else lives_l.color = 'white' end
			if back_button.contains?(e.x, e.y) then back_button.opacity = 0.3 if triggered
				else back_button.opacity = 1 end
			if play.contains?(e.x, e.y) then play.color = alt_button_colour
				else play.color = button_colour end
			if newgame.contains?(e.x, e.y) then newgame.color = alt_button_colour
				else newgame.color = button_colour end
			if background.contains?(e.x, e.y) then background.color = alt_button_colour
				else background.color = button_colour end
			if level_plus.contains?(e.x, e.y) then level_plus.color = alt_button_colour
				else level_plus.color = button_colour end
			if level_minus.contains?(e.x, e.y) then level_minus.color = alt_button_colour
				else level_minus.color = button_colour end
			if stats.contains?(e.x, e.y) then stats.color = alt_button_colour
				else stats.color = button_colour end
			if reset_stats.contains?(e.x, e.y) then reset_stats.color = alt_button_colour
				else reset_stats.color = button_colour end
			if about.contains?(e.x, e.y) then about.color = alt_button_colour
				else about.color = button_colour end
			if quit_.contains?(e.x, e.y) then quit_.color = alt_button_colour
				else quit_.color = button_colour end
			for key in nums.keys do if nums[key].contains?(e.x, e.y) then nums[key].color = colour_of_the_day
				else nums[key].color =  keycolour.rotate[key] ; nums[key].opacity = 0.5 end end
			if display.contains?(e.x, e.y) then display.opacity = 0.8
				else display.opacity = 0.5 end
			if display_c_l.contains?(e.x, e.y) then display_c_l.color = 'purple'
				else display_c_l.color = 'white' end
			if boat.contains?(e.x, e.y) and boattrigger then boat.x = e.x - boat.width/2 end
			if move_l.contains?(e.x, e.y) and keypadmove
				move_l.x, move_l.y = e.x - move_l.width/2, e.y - move_l.width/2
				for key in nums.keys do
					nums[key].remove
					nums_l[key].remove if !nums_l[key].nil? end
				for val in crystal_bank do val.remove end

				nums.clear ; nums_l.clear ; crystal_bank.clear
				display.x, display.y = move_l.x - 195, move_l.y - 150
				key_layout.x, key_layout.y = display.x - 10, display.y - 10
				display_l.x, display_l.y = display.x, display.y + 5
				display_c_l.x, display_c_l.y = display.x + display.width - 23, display.y + 15
				0.step(240, 20) do |temp|
					crystal_bank << Image.new( 'images/crystal.png', x: key_layout.x + temp, y: key_layout.y + key_layout.height - 35, z: -1)
				end

				6.times do |temp|
					crystal_bank << Image.new( 'images/crystal2.png', x: key_layout.x + temp * rand_white_crystal_y, y: key_layout.y + key_layout.height - 25, color: colour_of_the_day)
				end
				y, num = 10, 0
				4.times do 0.step(130, 65) do |temp|
						num += 1
						nums.merge! num => Rectangle.new(x: display.x + temp, y: display.y + display.height + y, height: 30, width: 50, color: keycolour.rotate[num])
						nums_l.merge! num => Text.new(num, x: display.x + temp + 20, y: display.y + display.height + y, font: 'fonts/arima.otf', color: 'white') if num <= 9
					end
					y += 40
				end
				rot.x, rot.y = display.x + 20, display.y + display.height + y - 40
				n0.x, n0.y =  display.x + 25 + 60, display.y + display.height + y - 40
				del.x, del.y = display.x + 30 + 120, display.y + display.height + y - 40
				nums.merge! 13 => Rectangle.new(x: display.x + 195, y: display.y + display.height + 10, height: 30, width: 50, color: keycolour.rotate[num + 1])
				minus_l.x, minus_l.y = display.x + 25 + 190, display.y + display.height + 10
				nums.merge! 14 => Rectangle.new(x: display.x + 195, y: display.y + display.height + 50, height: 30, width: 50, color: keycolour.rotate[num + 2])
				pause.x, pause.y = display.x + 25 + 190, display.y + display.height + 50
				key_layoutline1.x1 = key_layoutline2.x1 = key_layoutline3.x1 = key_layoutline3.x2 = key_layout.x
				key_layoutline1.y1 = key_layoutline1.y2 = key_layoutline3.y1 = key_layoutline4.y1 = key_layout.y
				key_layoutline1.x2 = key_layoutline2.x2 = key_layout.x + key_layout.width
				key_layoutline2.y1 = key_layoutline2.y2 = key_layout.y + key_layout.height
				key_layoutline3.y2 = key_layoutline4.y2 = key_layout.y + key_layout.height
				key_layoutline4.x1, key_layoutline4.x2 = key_layout.x + key_layout.width, key_layout.x + key_layout.width
			end
		end

		on :mouse_down do |e|
			if display_c_l.contains?(e.x, e.y) then pressed_key = '' ; display_c_l.color = colour_of_the_day end
			if notificationtime.contains?(e.x, e.y) then notificationtime.color = timeline.color = ['#ff963a', 'yellow', 'lime'].sample end
			if lives_l.contains?(e.x, e.y) or score_l.contains?(e.x, e.y) or show_menu.contains?(e.x, e.y)
					triggered = spacetrig % 2 == 0 ? true : false
					buttonpush.play
					spacetrig += 1
			end
			if e.x >= 20 and e.x <= 180 and e.y >= $height - 100 and e.y <= $height
				bird_spritesheet << Sprite.new(['images/bird_spritesheet.png', 'images/blue_bird_spritesheet.png', 'images/green_bird_spritesheet.png'].sample,
					clip_width: 30, loop: true, time: 120, x: e.x, y: e.y, z: 0, width: 25, height: 25)
			elsif boat.contains?(e.x, e.y) then boattrigger = true
			elsif water.contains?(e.x, e.y) then waternoise.play
			end
			if move_l.contains?(e.x, e.y) then keypadmove = true
				elsif background.contains?(e.x, e.y)
 					plop.play
					case %x(ruby SubWindows/colourwindow.rb).to_i
						when 0 then bg.color = 'blue'
						when 1 then bg.color = 'green'
						when 2 then bg.color = 'red'
						when 3 then bg.color = 'purple'
						when 4 then bg.color = 'lime'
						when 5 then bg.color = 'yellow'
						when 6 then bg.color = 'white'
						when 7 then bg.color = 'gray'
						when 8 then bg.color = 'silver'
						when 9 then bg.color = 'black'
						when 10 then bg.color = 'fuchsia'
						when 11 then bg.color = 'maroon'
						when 12 then bg.color = 'navy'
						when 13 then bg.color = 'brown'
						when 14 then bg.color = 'teal'
						when 15 then bg.color = 'olive'
						when 16 then bg.color = 'aqua'
						when 17 then bg.color = 'orange'
					end

				elsif level_plus.contains?(e.x, e.y) then plop.play ; if level < 9 then level += 1 ; old_level = level ; force_level = true ;music.play if force_level end
				elsif level_minus.contains?(e.x, e.y)
					plop.play
					if level > 1
						level -= 1
						force_level = true
						else force_level = false ; music.stop end
				elsif stats.contains?(e.x, e.y) then system('ruby', 'SubWindows/statswindow.rb') ; plop.play
				elsif reset_stats.contains?(e.x, e.y) then plop.play
				elsif about.contains?(e.x, e.y) then plop.play
				elsif quit_.contains?(e.x, e.y) then plop.play
				elsif back_button.contains?(e.x, e.y) or play.contains?(e.x, e.y) then triggered, spacetrig = false, spacetrig + 1 ; plop.play
				end
			for key in nums.keys do
				if nums[key].contains?(e.x, e.y) then
					keypress_sound.play
					nums[key].color = '#DFCEDF'
					if pressed_key.length <= 11
						pressed_key += key.to_s if key <= 9
						pressed_key += '0' if key == 11
						pressed_key += '-' if key == 13 and !pressed_key.include?('-')
						if key == 14 then triggered = spacetrig % 2 == 0 ? true : false ; spacetrig += 1 end
					end
					for key in nums.keys do nums[key].color = keycolour.rotate![0] end if key == 10
					pressed_key = pressed_key[0..-2] if key == 12
				end
			end
		end

		on :mouse_up do |e|
			if reset_stats.contains?(e.x, e.y)
				if %x(ruby SubWindows/resetstatsconfirm.rb).to_s.include? "RESET" then $info.truncate(0) ; exit! end
			end
			if quit_.contains?(e.x, e.y) then close if %x(ruby SubWindows/quitwindow.rb).include?("QUIT") end
			Thread.new { system('ruby SubWindows/aboutwindow.rb') } if about.contains?(e.x, e.y)
			if display_c_l.contains?(e.x, e.y) then display_c_l.color = 'red' end
			if newgame.contains?(e.x, e.y)
				confirm = %x(ruby SubWindows/newgameconfirmwindow.rb).to_s if started
				confirm = "NEWGAME" unless started
				if confirm.include? 'NEWGAME'
					Sound.new('sounds/k2.mp3').play
					glowparticles.alpha = 1
					started = true
					tada.play
					h.clear
					spacetrig += 1
					started, triggered, pressed_key, inittime, score, lives, restriction, speed = true, false, '', t.call('%s'), 0, 9, 1, 0.7
					missed, answered = 0, 0
					$info.puts("    New Game at: #{t.call('%T')}")
				end
			end
			keypadmove, boattrigger = false, false
		end

		on :mouse_scroll do|e| bg.color = ['random', 'white'].sample end
		update do
			i += 1
			hoverparticles.draw
			if timehover
				timeline.x1 -= 2 if timeline.x1 > notificationtime.x
				timeline.x2  += 2 if timeline.x2 < notificationtime.x + notificationtime.width
			else
				timeline.x1 += 2 if timeline.x1 < notificationtime.x + notificationtime.width/2
				timeline.x2 -= 2 if timeline.x2 > notificationtime.x + notificationtime.width/2
			end
			liveboost.y -= 5 if liveboost.y >= -liveboost.height
			liveboost.opacity -= 0.1 if liveboost.opacity >= 0
			livereduce.y -= 10 if livereduce.y >= 0
			livereduce.opacity -= 0.2 if livereduce.opacity >= 0
			score_menu.text = "Score: #{score}"
			highestscore_menu.text = "Highest Score: #{high_score}"
			lives_menu.text = "Remaining Lives: #{lives}"
			water.y1 = Math.sin(i/10)/3 + water.y1
			water.y2 = Math.cos(i/10)/4 + water.y2
			bird_spritesheet.each do |val|
				unless val.x <= -val.width
					val.play
					val.x -= 1
					val.y += Math.sin(i/rand(15..20))
				else
					val.remove
					bird_spritesheet.delete(val)
				end
			end
			boatglow.opacity -= 0.01 if boatglow.opacity >= 0
			glowparticles.float(magic=true, x=rand(inittext.x..inittext.x + inittext.width), inittext.height + 100)
			smokes.draw(false)
			magicice.draw(true)
			magicice.shuffle(rand(0..$width), rand(0..$height)) if time.to_i % 2 == 0
			boatglow.x, boatglow.y = boat.x, boat.y
			if boat.x <= $width/2 - 220 and lives > 0
				boat.y = water.y1 - boat.height - 5
				boat.x += 1 if !(time.to_i % 7 == 0)
				boat.x += 0.3 if time.to_i % 7 == 0
			elsif boat.x >= $width/2 - 220 and boat.x <= $width/2 + 245 and lives > 0
				boat.y = (water.y2 + water.y1)/2 - boat.height - 5
				boat.x += 1.3 if !(time.to_i % 8 == 0)
			else
				boat.y = water.y2 - boat.height - 5 if lives > 0
				boat.x += 1 if !(time.to_i % 9 == 0)
			end
			boat.x = -boat.width if boat.x >= $width + boat.width
			if lives <= 0
				boat.y += 1 if boat.y >= -boat.height
				boat.x += 1 if boat.x >= -boat.width
				inittext.opacity = 1
				inittext.text = 'Game Over'
				inittext.x = inittext.width/2 + $width/8
				started = false
				h.keys.each do |key| h[key].remove ; h.delete(key) ; img[key].remove ; img.delete(key) end
			end
			magicparticles.float(fizzing=false, magic=true, x=rand(key_layout.x..key_layout.x + key_layout.width), key_layout.y + key_layout.height - 200)
			treeparticles.float(fizzing=true, magic=true, x=rand(0..150), rand($height - 300..$height - 50))
			particles.float(fizzing=false, magic=false, x=rand(0..$width), $height - 220)
			flake1.y += 1
			flake1.opacity -= rand(0.003..0.006)

			flakehash << Image.new( 'images/flake1.png', x: rand(0..$width), y: rand(-$height..0)) if flakehash.size < 25
				for val in flakehash
					val.y += 0.5
					val.opacity -= 0.0003
					val.rotate += rand(1..3)
					val.width += 0.003
					val.height += 0.003
				if val.y >= $height
					val.remove
					flakehash.delete(val)
				end
			end
			move_l.color = 'white' unless keypadmove
			move_l.color = 'fuchsia' if keypadmove

			if colourcloud.x >= -colourcloud.width and colourcloudswitch then colourcloud.x -= 0.5
			else
				colourcloud.x = $width + colourcloud.width
				colourcloud.y = rand(50..$height - 400)
				colourcloudswitch = time.to_i % 25 == 0
				end
			if cloud1.x >= -cloud1.width and cloud == 1 then cloud1.x -= 1 ; selected_cloud = cloud1
				elsif cloud2.x >= -cloud2.width and cloud == 2 then cloud2.x -= 1 ; selected_cloud = cloud2
				elsif cloud3.x >= -cloud3.width and cloud == 3 then cloud3.x -= 1 ; selected_cloud = cloud3
				elsif cloud4.x >= -cloud4.width and cloud == 4 then cloud4.x -= 1 ; selected_cloud = cloud4
				end
			if selected_cloud.x <= -selected_cloud.width
				selected_cloud.x = $width
				cloud = rand(1..4)
				selected_cloud.y = rand(0..400)
				selected_cloud.color = %w(white #3ce3b4 white #ff50a6 white black white lime white).sample
				selected_cloud.opacity = 0.3
			end

			display_l.text = pressed_key
			display_l.x = display.x + display.width - display_l.width - display_c_l.width - 15
			for key in nums.keys do nums[key].opacity -= 0.005 if nums[key].opacity > 0.5 end

			score_l.text = "Score: #{score}    HighScore: #{high_score}"
			score_l.x = notificationline.x2 - score_l.width - 10

			answered_l.text = "Correct: #{answered}"
			missed_l.text = "Missed: #{missed}"

			lives_l.text = "Level: #{level}    Lives: #{lives}"
			lives_l.x = notificationline.x2 - lives_l.width - 10
			lives_l.y = score_l.y + score_l.height - 5

			notificationline.opacity -= 0.015 if notificationline.opacity >= 0.3
			notificationtime.text = t.call('%T')
			notificationtime.x = $width/2 - notificationtime.width/2

			unless triggered
				unless started then glowparticles.alpha = 1 else glowparticles.alpha = 0 end
				inittext.x -= 12 if inittext.x > inittext.width/2 - $width/4
				menu_box.width -= 10 if menu_box.width >= 0
				back_button.x -= 10 if back_button.x >= -back_button.width
				play.x -= 10 if play.x >= -play.width - 20
				newgame.x -= 10 if newgame.x >= -newgame.width - 20
				background.x -= 10 if background.x >= -background.width - 20
				level_plus.x -= 10 if level_plus.x >= -level_plus.width - 20
				level_minus.x -= 10 if level_minus.x >= -level_minus.width - 20
				stats.x -= 10 if stats.x >= -stats.width - 20
				reset_stats.x -= 10 if reset_stats.x >= -reset_stats.width - 20
				about.x -= 10 if about.x >= -about.width - 20
				quit_.x -= 10 if quit_.x >= -quit_.width - 20

				play_l.x -= 10 if play_l.x >= -play_l.width * 4
				newgame_l.x -= 10 if newgame_l.x >= -newgame_l.width * 2
				background_l.x -= 10 if background_l.x >= - background_l.width * 1.8
				level_plus_l.x -= 10 if level_plus_l.x >= -level_plus_l.width * 2
				level_minus_l.x -= 10 if level_minus_l.x >= -level_minus_l.width * 2
				stats_l.x -= 10 if stats_l.x >= -stats_l.width * 2
				reset_stats_l.x -= 10 if reset_stats_l.x >= -reset_stats_l.width * 2
				about_l.x -= 10 if about_l.x >= -about_l.width * 3
				quit__l.x -= 10 if quit__l.x >= -quit__l.width * 4
				menu_text.x = menu_box.width/2 - menu_text.width - 20

				menuscorebox.x -= 10 if menuscorebox.x >= -menuscorebox.width
				menuscorebox.opacity -= 0.06 if menuscorebox.opacity >= 0
				score_menu.opacity -= 0.03 if score_menu.opacity >= 0
				highestscore_menu.opacity -= 0.015 if highestscore_menu.opacity >= 0
				lives_menu.opacity -= 0.0075 if lives_menu.opacity >= 0
				answered_menu.opacity -= 0.075 if answered_menu.opacity > 0
				answered_l.opacity -= 0.01 if answered_l.opacity > 0
				missed_l.opacity -= 0.01 if missed_l.opacity > 0
				score_menu.x -= 10 if score_menu.x >= -score_menu.width
				highestscore_menu.x -= 10 if highestscore_menu.x >= -highestscore_menu.width
				lives_menu.x -= 10 if lives_menu.x >= -lives_menu.width
				answered_menu.x -= 10 if answered_menu.x >= -answered_menu.width
				answered_l.x -= 10 if answered_l.x >= -answered_l.width
				missed_l.x -= 10 if missed_l.x >= -missed_l.width
			else
				inittext.x += 15 if inittext.x <= $width/2 - inittext.width
				inittext.text = "Paused" if started
				inittext.x += 1 if inittext.x < $width/4 if started
				inittext.opacity = 1
				menu_text.x = menu_box.width/2 - menu_text.width - 20
				menu_box.width += 10 if menu_box.width <= 250
				notificationline.opacity = 1
				play.x += 10 if play.x < 10
				newgame.x += 10 if newgame.x < 10
				background.x += 10 if background.x < 10
				level_plus.x += 10 if level_plus.x < 10
				level_minus.x += 10 if level_minus.x < level_plus.width + 25
				stats.x += 10 if stats.x < 10
				reset_stats.x += 10 if reset_stats.x < stats.width + 25
				about.x += 10 if about.x < 10
				quit_.x += 10 if quit_.x < 10
				back_button.x += 1 if back_button.x < 10

				play.opacity = newgame.opacity = background.opacity = level_plus.opacity = level_minus.opacity = stats.opacity = reset_stats.opacity = about.opacity = quit_.opacity = 10
				play_l.opacity = newgame_l.opacity = background_l.opacity = level_plus_l.opacity = level_minus_l.opacity = stats_l.opacity = reset_stats_l.opacity = about_l.opacity = quit__l.opacity = 1
				missed_l.opacity = answered_l.opacity = 1

				play_l.x += 10 if play_l.x <= play_l.width + 60
				newgame_l.x += 10 if newgame_l.x < newgame_l.width - 10
				background_l.x += 10 if background_l.x < background_l.width - 30
				level_plus_l.x += 10 if level_plus_l.x < level_plus.x + level_plus.width - level_plus_l.width - 25
				level_minus_l.x += 10 if level_minus_l.x < level_minus.x + level_minus.width - level_minus_l.width - 25
				stats_l.x += 10 if stats_l.x < stats.x + stats.width - stats_l.width - 35
				reset_stats_l.x += 10 if reset_stats_l.x < reset_stats.x + reset_stats.width - reset_stats_l.width - 35
				about_l.x += 10 if about_l.x < about_l.width + 45
				quit__l.x += 10 if quit__l.x < quit__l.width + 70
				menuscorebox.x += 10 if menuscorebox.x <= quit_.x - 10
				menuscorebox.opacity = answered_menu.opacity = score_menu.opacity = highestscore_menu.opacity = lives_menu.opacity = 1 if menuscorebox.opacity <= 1
				score_menu.x += 5 if score_menu.x <= menu_box.x + 25
				highestscore_menu.x += 5 if highestscore_menu.x <= menu_box.x + 25
				lives_menu.x += 5 if lives_menu.x <= menu_box.x + 25
				answered_menu.x += 10 if answered_menu.x <= quit_.x - 10
				answered_l.x += 5 if answered_l.x <= menu_box.x + 25
				missed_l.x += 5 if missed_l.x <= menu_box.x + 25

				for key in h.keys do
					h[key].opacity -= 0.1 if h[key].opacity > 0
					img[key].opacity -= 0.1 if img[key].opacity > 0
				end
			end
			# Begin the game
			if !triggered and started
				inittext.opacity -= 0.02

				# uncomment the following line for enabling autoplay (no human interaction needed to play)
				# for key in h.keys do pressed_key = eval(h[key].text).to_s if h[key].y >= rand(50..$height - 200) end

				for key in h.keys do
					h[key].y += speed
					h[key].x += Math.cos(i/10)
					img[key].y = h[key].y - 15
					img[key].x += Math.cos(i/10)
					if h[key].y >= boat.y
						livereduce.x, livereduce.y, livereduce.opacity = h[key].x, h[key].y, 1
						score -= 500
						missed += 1
						lives -= 1 if lives >= 1
						speed -= 0.03 if speed >= 0.5
						restriction -= 2 if restriction >= 5
						boatglow.opacity = 1
						h[key].remove
						img[key].remove
						h.delete(key)
						img.delete(key)
						sizzling.play
					end
					unless h[key].nil?
						h[key].opacity += 0.05 if h[key].y >= notificationline.y2 and h[key].opacity < 1
						img[key].opacity += 0.05 if img[key].y >= notificationline.y2 and img[key].opacity < 1
						if h[key].y >= boat.y - 200
							smokes.shuffle(boat.x, boat.y + boat.height/2)
							img[key].color = '#00ff50'
							img[key].color = 'blue' if time.to_i % 2 == 0
							boat.x -= speed * 8 if boat.x > h[key].x
							boat.x += speed * 8 if boat.x < h[key].x
						end

						if pressed_key.to_i == eval(h[key].text).to_i and !pressed_key.empty? and pressed_key != '-'
							if img[key]. == 'images/waterbonus.png'
								lives += 1
								liveboost.opacity, liveboost.x, liveboost.y = 1, h[key].x, h[key].y
								score += 500 if %w(1 2 3).include?(level.to_s)
								score += 1500 if %w(4 5 6).include?(level.to_s)
								score += 2500 if %w(7 8 9).include?(level.to_s)
							end
							robot_blip.play
							pos = h[key].x, h[key].y
							randflake = flakehash.sample
						 	if randflake.y <= 0-randflake.height then randflake.x, randflake.y = pos end
							h[key].remove
							h.delete(key)
							img[key].remove
							img.delete(key)
							pressed_key = ''
							answered += 1
							speed += 0.03

							restriction += 1 if answered % rand(3..6) == 1
							score += 1000 if level == 1
							score += 1500 if level == 2
							score += 2000 if level == 3
							score += 2500 if level == 4
							score += 3000 if level == 5
							score += 3500 if level == 6
							score += 4000 if level == 7
							score += 4500 if level == 8
							score += 5000 if level == 9
							high_score = score if score > high_score
							particles.alpha = 1
						end
					end
				end
				if time.next == t.call('%s')
					if h.count <= restriction
						possible_num = generate.call(level)
						h.keys.each do |key|
							while eval(h[key].text).to_s.start_with?(eval(possible_num.text).to_s) or eval(possible_num.text).to_s.start_with?(eval(h[key].text).to_s) do
								possible_num.opacity = 0 ; possible_num.remove ; possible_num = generate.call(level)
							end
						end
						h.merge! i => possible_num
						if (!(answered % 15 == 0) or ((time.to_i - inittime.to_i) < 3))
							img.merge! i => c = Image.new('images/water.png', x: h[i].x, y: h[i].y - 15, z: -1) ; c.opacity = 0
						else
							img.merge! i => c = Image.new('images/waterbonus.png', x: h[i].x, y: h[i].y - 15, z: -1) ; c.opacity = 0
						end
					end
				end
				if level >= 2 then speed -= 0.0002 if speed >= 0.6 end

				unless force_level
					if score < 20000 then level = 1
						elsif score >= 20000 and score < 30000 then level = 2
						elsif score >= 30000 and score < 50000 then level = 3
						elsif score >= 50000 and score < 75000 then level = 4
						elsif score >= 75000 and score < 100000 then level = 5
						elsif score >= 100000 and score < 150000 then level = 6
						elsif score >= 150000 and score < 225000 then level = 7
						elsif score >= 225000 and score < 290000 then level = 8
						elsif score >= 290000 then level = 9
					end
				end
			end
			time = t.call('%s')
			if old_level < level
				old_level = level
				lives += 3
				tada.play
				inittext.text, inittext.opacity, inittext.x = "Level Up", 1, $width - inittext.width
			end
		end
	show
	$info.puts("    Exiting With Highest Score: #{high_score}")
	$info.puts("Game ended at #{Time.new.strftime('%T')}\n\n")
end
main
