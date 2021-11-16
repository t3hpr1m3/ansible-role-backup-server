#!/usr/bin/env bash

[ -n "${BACKUPS_CONFIG_SOURCED+x}" ] && return

declare BACKUPS_CONFIG_FILE
declare BACKUPS_CONFIG_ROOT
declare BACKUPS_CONFIG_D
declare BACKUPS_CONFIG_BIN
declare BACKUPS_CONFIG_ETC
declare BACKUPS_CONFIG_LIB
declare BACKUPS_CONFIG_LOG
declare BACKUPS_CONFIG_RUN
declare BACKUPS_CONFIG_TMP
declare BACKUPS_CONFIG_VAR
declare BACKUPS_CONFIG_PID_FILE

function backups::config::init {
	BACKUPS_CONFIG_ROOT="$(jq -r '.backup_root' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_D="$(jq -r '.configuration_d' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_BIN="$(jq -r '.bin' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_ETC="$(jq -r '.etc' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_LIB="$(jq -r '.lib' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_LOG="$(jq -r '.log' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_RUN="$(jq -r '.run' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_TMP="$(jq -r '.tmp' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_VAR="$(jq -r '.var' $BACKUPS_CONFIG_FILE)"
	BACKUPS_CONFIG_PID_FILE="$(jq -r '.pid_file' $BACKUPS_CONFIG_FILE)"
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

declare -r BACKUPS_CONFIG_SOURCED=1

# vim: filetype=sh ts=4 sts=4 sw=4 noet
