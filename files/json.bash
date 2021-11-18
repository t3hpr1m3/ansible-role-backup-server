#!/usr/bin/env bash

[ -n "${BACKUPS_JSON_SOURCED+x}" ] && return

function backups::json::get_string {
	declare -r json="$1"
	declare -r key="$2"
	echo "${json}" | jq -r '(.'${key}') // empty'
}

function backups::json::get_array {
	declare -r json="$1"
	declare -r key="$2"
	echo "${json}" | jq -c '(.'${key}') // empty | .[]'
}

declare -r BACKUPS_JSON_SOURCED=1

# vim: filetype=sh ts=4 sts=4 sw=4 noet
