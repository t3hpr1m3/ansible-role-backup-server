#!/usr/bin/env bash

[ -n "${BACKUPS_UTILS_SOURCED+x}" ] && return

function backups::utils::normalize_slashes {
	declare -r segment="$1"
	declare cleaned="$(echo $segment | tr -s /)"
	[[ ${#cleaned} -gt 1 ]] && cleaned="${cleaned%/}"
	echo "${cleaned}"
}

function backups::utils::join_paths {
	declare -a paths=()
	declare path=""

	for segment in "$@"; do
		paths+=("$(backups::utils::normalize_slashes "${segment}")")
	done
	declare -r IFS="/"
	echo "${paths[*]}"
}

function backups::utils::error_exit {
	backups::log::error "$1"
	exit 1
}

declare -r BACKUPS_UTILS_SOURCED=1

# vim: filetype=sh ts=4 sts=4 sw=4 noet
