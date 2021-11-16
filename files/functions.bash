cleanup() {
	trap - SIGINT SIGTERM ERR EXIT
	backups::log::teardown
}

normalize_slashes() {
	local dir=$(echo $1 | tr -s /)
	echo "${dir%/}"
}

error_exit() {
	echo -e "\n$1\n" 1>&2
	exit 1
}

# Whether or not we should perform a trial run
dry_run=0

quiet=0

# Print more progress information
verbose=0

# vim: filetype=sh ts=4 sts=4 sw=4 noet
