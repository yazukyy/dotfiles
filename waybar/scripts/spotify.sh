#!/bin/bash

control_spotify() {
	dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.$1 >/dev/null 2>&1
}

icon_previous() {
	echo "<span font='FontAwesome'></span>"
}

icon_next() {
	echo "<span font='FontAwesome'></span>"
}

update_waybar_icon() {
	player_status=$(playerctl status)
	if [ "$player_status" = "Playing" ]; then
		echo ""
	elif [ "$player_status" = "Paused" ]; then
		echo ""
	else
		echo
	fi
}

status_check() {
	if pgrep -x "spotify" >/dev/null; then
		exit 0
	else
		exit 1
	fi
}

update_songtitle_icon() {
	player_status=$(playerctl status)
	if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
		echo "<span color='#1DB954'> </span> $(playerctl metadata artist) - $(playerctl metadata title)"
	else
		echo
	fi
}

toggle_spotify_workspace() {
	PREV_WS_FILE="/tmp/prev_workspace"

	CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')

	SPOTIFY_WS=$(hyprctl -j clients | jq -r 'map(select(.class == "Spotify"))[0].workspace.id')

	if [ "$CURRENT_WS" == "$SPOTIFY_WS" ]; then
		if [ -f "$PREV_WS_FILE" ]; then
			PREV_WS=$(cat "$PREV_WS_FILE")
			hyprctl dispatch workspace "$PREV_WS"
			rm "$PREV_WS_FILE"
		else
			echo
		fi
	else
		echo "$CURRENT_WS" >"$PREV_WS_FILE"
		hyprctl dispatch workspace "$SPOTIFY_WS"
	fi
}

case "$1" in
"previous")
	control_spotify "Previous"
	;;
"pause")
	control_spotify "PlayPause"
	;;
"next")
	control_spotify "Next"
	;;
"icon-pause")
	update_waybar_icon
	;;
"songtitle_icon")
	update_songtitle_icon
	;;
"status-check")
	status_check
	;;
"icon-previous")
	icon_previous
	;;
"icon-next")
	icon_next
	;;
"toggle-workspace")
	toggle_spotify_workspace
	;;
*)
	echo "Unknown action: $1"
	exit 1
	;;
esac
