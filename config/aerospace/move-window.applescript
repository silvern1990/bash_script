use framework "AppKit"
use scripting additions

on run argv
	set pos to item 1 of argv

	tell application "System Events"
		set frontApp to name of first application process whose frontmost is true
	end tell

	-- mainScreen returns the screen containing the currently focused (key) window
	set mainScr to current application's NSScreen's mainScreen()
	set vf to mainScr's visibleFrame()
	set allScreens to current application's NSScreen's screens()
	set primaryH to (item 2 of item 2 of ((item 1 of allScreens)'s frame())) as real

	-- visibleFrame excludes menu bar and dock
	set scrX to (item 1 of item 1 of vf) as real
	set scrCocoaY to (item 2 of item 1 of vf) as real
	set scrW to (item 1 of item 2 of vf) as real
	set scrH to (item 2 of item 2 of vf) as real
	set scrY to primaryH - scrCocoaY - scrH

	set halfW to scrW / 2
	set halfH to scrH / 2

	if pos is "q1" then
		set newBounds to {scrX + halfW, scrY, scrX + scrW, scrY + halfH}
	else if pos is "q2" then
		set newBounds to {scrX, scrY, scrX + halfW, scrY + halfH}
	else if pos is "q3" then
		set newBounds to {scrX, scrY + halfH, scrX + halfW, scrY + scrH}
	else if pos is "q4" then
		set newBounds to {scrX + halfW, scrY + halfH, scrX + scrW, scrY + scrH}
	else if pos is "full" then
		set newBounds to {scrX, scrY, scrX + scrW, scrY + scrH}
	else if pos is "left" then
		set newBounds to {scrX, scrY, scrX + halfW, scrY + scrH}
	else if pos is "right" then
		set newBounds to {scrX + halfW, scrY, scrX + scrW, scrY + scrH}
	else if pos is "top" then
		set newBounds to {scrX, scrY, scrX + scrW, scrY + halfH}
	else if pos is "bottom" then
		set newBounds to {scrX, scrY + halfH, scrX + scrW, scrY + scrH}
	end if

	tell application frontApp
		set bounds of window 1 to newBounds
	end tell
end run