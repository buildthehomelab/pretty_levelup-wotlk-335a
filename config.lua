local _, private = ...;

private.config = {
	--	technical
	scale 		 = 1, 		 -- change size
	sound 		 = true, 	 -- play sound
	sound_file	 = "levelup.mp3", -- file in the assets folder (.mp3, .ogg or .wav)
	time 		 = 0.30, 	 -- time (delay) in seconds to show next toast (update time)
	numbuttons 	 = 4, 		 -- how many toasts to show at a time (max 8)
	anims		 = true,	 -- play animations
	offset_x 	 = 4,		 -- offset between toasts, if first is displayed then second will be higher/lower from previous
	point_x		 = 0,		 -- position of toast by X
	point_y		 = 120,      -- position of toast by Y

	--	look
	spell_quality = 4,		 -- border/name color of the toast (2 green, 3 blue, 4 purple, 5 orange, 7 gold)
};
