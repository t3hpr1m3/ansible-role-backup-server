#!/usr/bin/env bash

[ -n "${BACKUPS_CONFIG_SOURCED+x}" ] && return

declare BACKUPS_CONFIG_FILE="${BACKUPS_CONFIG_FILE:-/etc/backups.json}"
declare BACKUPS_CONFIG_DATA="${BACKUPS_CONFIG_DATA:-{}}"
declare BACKUPS_CONFIG_DATA_DIR="${BACKUPS_CONFIG_DATA_DIR:-/srv/backups}"
declare BACKUPS_CONFIG_BIN_DIR="${BACKUPS_CONFIG_BIN_DIR:-/usr/local/bin}"
declare BACKUPS_CONFIG_ETC_DIR="${BACKUPS_CONFIG_ETC_DIR:-/etc/backups}"
declare BACKUPS_CONFIG_LIB_DIR="${BACKUPS_CONFIG_LIB_DIR:-/usr/local/lib/backups}"
declare BACKUPS_CONFIG_LOG_DIR="${BACKUPS_CONFIG_LOG_DIR:-/var/log/backups}"
declare BACKUPS_CONFIG_RUN_DIR="${BACKUPS_CONFIG_RUN_DIR:-/var/run/backups}"
declare BACKUPS_CONFIG_TMP_DIR="${BACKUPS_CONFIG_TMP_DIR:-/var/tmp/backups}"
declare BACKUPS_CONFIG_VAR_DIR="${BACKUPS_CONFIG_VAR_DIR:-/var/lib/backups}"
declare BACKUPS_CONFIG_PID_FILE="${BACKUPS_CONFIG_PID_FILE:-}"
declare BACKUPS_CONFIG_CLIENTS="${BACKUPS_CONFIG_CLIENTS:-}"

function backups::config::init {
	BACKUPS_CONFIG_DATA="$(cat $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_DATA_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'data_dir')"
	BACKUPS_CONFIG_BIN_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'bin_dir')"
	BACKUPS_CONFIG_ETC_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'etc_dir')"
	BACKUPS_CONFIG_LIB_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'lib_dir')"
	BACKUPS_CONFIG_LOG_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'log_dir')"
	BACKUPS_CONFIG_RUN_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'run_dir')"
	BACKUPS_CONFIG_TMP_DIR="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'tmp_dir')"
	BACKUPS_CONFIG_PID_FILE="$(backups::json::get_string \
		"${BACKUPS_CONFIG_DATA}" 'pid_file')"
	BACKUPS_CONFIG_CLIENTS="$(backups::json::get_array \
		"${BACKUPS_CONFIG_DATA}" 'clients')"
}

function backups::config::opts {
	echo "c:"
}

function backups::config::parse_param {
	declare -r opt="$1"
	declare -r optarg="${2:-}"
	declare -i rc=-1

	case "$OPT" in
		c | config)
			BACKUPS_CONFIG_FILE="$OPTARG"
			rc=0
			;;
	esac

	return $rc
}

function backups::config::data {
	echo "${BACKUPS_CONFIG_DATA}"
}

function backups::config::data_dir {
	echo "${BACKUPS_CONFIG_DATA_DIR}"
}

function backups::config::bin_dir {
	echo "${BACKUPS_CONFIG_BIN_DIR}"
}

function backups::config::etc_dir {
	echo "${BACKUPS_CONFIG_ETC_DIR}"
}

function backups::config::lib_dir {
	echo "${BACKUPS_CONFIG_LIB_DIR}"
}

function backups::config::log_dir {
	echo "${BACKUPS_CONFIG_LOG_DIR}"
}

function backups::config::run_dir {
	echo "${BACKUPS_CONFIG_RUN_DIR}"
}

function backups::config::tmp_dir {
	echo "${BACKUPS_CONFIG_TMP_DIR}"
}

function backups::config::pid_file {
	echo "${BACKUPS_CONFIG_PID_FILE}"
}

function backups::config::clients {
	echo "${BACKUPS_CONFIG_CLIENTS}"
}

declare -r BACKUPS_CONFIG_SOURCED=1

# vim: filetype=sh ts=4 sts=4 sw=4 noet
