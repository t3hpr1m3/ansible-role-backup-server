#!/usr/bin/env bash

[ -n "${BACKUPS_LOG_SOURCED+x}" ] && return

declare -r BACKUPS_LOG_ERROR=0
declare -r BACKUPS_LOG_WARN=1
declare -r BACKUPS_LOG_INFO=2
declare -r BACKUPS_LOG_DEBUG=3

declare -i BACKUPS_LOG_QUIET="${BACKUPS_LOG_QUIET:-0}"
declare -i BACKUPS_LOG_VERBOSE="${BACKUPS_LOG_VERBOSE:-0}"
declare -i BACKUPS_LOG_LEVEL="${BACKUPS_LOG_LEVEL:-$BACKUPS_LOG_WARN}"

declare -i BACKUPS_LOG_STDOUT_PID=-1
declare -i BACKUPS_LOG_STDOUT_FD=-1
declare BACKUPS_LOG_STDOUT_FIFO=/tmp/backups.stdout

declare -i BACKUPS_LOG_STDERR_PID=-1
declare -i BACKUPS_LOG_STDERR_FD=-1
declare BACKUPS_LOG_STDERR_FIFO=/tmp/backups.stderr

declare BACKUPS_LOG_FILE="${BACKUPS_LOG_FILE:-/var/log/backups.log}"

function backups::log::init {
	declare log_path="$1"
	declare filename="$2"

	if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
		NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
	else
		NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
	fi

	BACKUPS_LOG_FILE="$(backups::utils::join_paths "${log_path}" "${filename}")"

	backups::log::start_watchers
}

function backups::log::teardown {
	backups::log::stop_watchers
}

function backups::log::watch_stdout {
	[[ -p "${BACKUPS_LOG_STDOUT_FIFO}" ]] || mkfifo ${BACKUPS_LOG_STDOUT_FIFO}
	function _process_stdout {
		declare line severity message
		# Close any open fd's (will hold the process open)
		[[ $BACKUPS_LOG_STDOUT_FD -ne -1 ]] && exec {BACKUPS_LOG_STDOUT_FD}>&-
		[[ $BACKUPS_LOG_STDERR_FD -ne -1 ]] && exec {BACKUPS_LOG_STDERR_FD}>&-
		exec 5<${BACKUPS_LOG_STDOUT_FIFO}
		while read -r -u 5 line; do
			declare timestamp="$(backups::log::timestamp)"
			if [[ ${line} =~ ^::([0-9])::(.*)$ ]]; then
				severity="${BASH_REMATCH[1]}"
				message="${BASH_REMATCH[2]}"
				echo -e "${timestamp} $(backups::log::severity $severity): $message" >>${BACKUPS_LOG_FILE}
			else
				message="${line}"
				echo -e "${timestamp}: $message" >>${BACKUPS_LOG_FILE}
			fi
			[[ $BACKUPS_LOG_QUIET -eq 0 ]] && echo "${message}" >&2
		done
	}
	_process_stdout &
	BACKUPS_LOG_STDOUT_PID=$!
	exec {BACKUPS_LOG_STDOUT_FD}>"${BACKUPS_LOG_STDOUT_FIFO}"
	return 0
}

function backups::log::watch_stderr {

	[[ -p "${BACKUPS_LOG_STDERR_FIFO}" ]] || mkfifo ${BACKUPS_LOG_STDERR_FIFO}

	function _process_stderr {
		declare -i fd severity
		declare line message timestamp

		# Close any open fd's (will hold the process open)
		[[ $BACKUPS_LOG_STDOUT_FD -ne -1 ]] && exec {BACKUPS_LOG_STDOUT_FD}>&-
		[[ $BACKUPS_LOG_STDERR_FD -ne -1 ]] && exec {BACKUPS_LOG_STDERR_FD}>&-

		# Setup the log reader readirection
		exec {fd}<${BACKUPS_LOG_STDERR_FIFO}

		# Read the stream, line by line
		while read -r -u $fd line; do
			timestamp="$(backups::log::timestamp)"
			# Check for ::<severity>:: at the head of the message
			if [[ ${line} =~ ^::([0-9])::(.*)$ ]]; then
				severity="${BASH_REMATCH[1]}"
				message="${BASH_REMATCH[2]}"
				echo -e "${timestamp} $(backups::log::severity $severity): $message" >>${BACKUPS_LOG_FILE}
			else
				message="${line}"
				echo -e "${timestamp}: $message" >>${BACKUPS_LOG_FILE}
			fi

			# output to the terminal
			[[ $BACKUPS_LOG_QUIET -eq 0 ]] && echo "${message}" >&2
		done
	}

	# start the backround process
	_process_stderr &
	BACKUPS_LOG_STDERR_PID=$!

	# setup the log writer redirection
	exec {BACKUPS_LOG_STDERR_FD}>"${BACKUPS_LOG_STDERR_FIFO}"
	return 0
}

function backups::log::opts {
	echo "qv"
}

function backups::log::parse_param {
	declare -r opt="$1"
	declare -r optarg="${2:-}"
	declare -i rc=-1

	case "$OPT" in
		q | quiet)
			BACKUPS_LOG_QUIET=1
			BACKUPS_LOG_LEVEL=$BACKUPS_LOG_ERROR
			rc=0
			;;
		v | verbose)
			BACKUPS_LOG_VERBOSE=$((BACKUPS_LOG_VERBOSE+1))
			if [[ $BACKUPS_LOG_QUIET -eq 0 ]]; then
				BACKUPS_LOG_LEVEL=$((BACKUPS_LOG_WARN+$BACKUPS_LOG_VERBOSE))
			fi
			rc=0
			;;
	esac

	return $rc
}

function backups::log::timestamp {
	read d < <(date --rfc-3339=seconds)
	echo -n "[${CYAN}${d}${NOFORMAT}]"
}

function backups::log::severity {
	declare -r level=$1
	case "$level" in
		$BACKUPS_LOG_ERROR )
			echo "${RED}ERROR${NOFORMAT}"
			;;
		$BACKUPS_LOG_WARN )
			echo "${YELLOW} WARN${NOFORMAT}"
			;;
		$BACKUPS_LOG_INFO )
			echo "${GREEN} INFO${NOFORMAT}"
			;;
		$BACKUPS_LOG_DEBUG )
			echo "${GREEN}DEBUG${NOFORMAT}"
			;;
	esac
}

function backups::log::log {
	declare -ri level="$1"
	declare -r msg="$2"

	if [[ $level -eq -1 ]]; then
		if [[ $BACKUPS_LOG_STDOUT_FD -gt 0 ]]; then
			echo -e "${msg}" >&${BACKUPS_LOG_STDOUT_FD}
		else
			echo -e "${msg}" >&1
		fi
	else
		if [[ $level -le $BACKUPS_LOG_LEVEL ]]; then
			if [[ $level -le $BACKUPS_LOG_ERROR ]]; then
				if [[ $BACKUPS_LOG_STDERR_PID -gt 0 ]]; then
					echo -e "::$level::$msg" >&${BACKUPS_LOG_STDERR_FD}
				else
					echo -e "${msg}" >&2
				fi
			else
				if [[ $BACKUPS_LOG_STDOUT_PID -gt 0 ]]; then
					echo -e "::$level::$msg" >&${BACKUPS_LOG_STDOUT_FD}
				else
					echo -e "${msg}" >&1
				fi
			fi
		fi
	fi
}

function backups::log::error {
	backups::log::log $BACKUPS_LOG_ERROR "$@"
}

function backups::log::warn {
	backups::log::log $BACKUPS_LOG_WARN "$@"
}

function backups::log::info {
	backups::log::log $BACKUPS_LOG_INFO "$@"
}

function backups::log::debug {
	backups::log::log $BACKUPS_LOG_DEBUG "$@"
}

function backups::log::plain {
	backups::log::log -1 "$@"
}

function backups::log::stdout_fd {
	echo "${BACKUPS_LOG_STDOUT_FD}"
}

function backups::log::stderr_fd {
	echo "${BACKUPS_LOG_STDERR_FD}"
}

function backups::log::stop_watchers {
	[[ $BACKUPS_LOG_STDOUT_PID -ge 0 ]] && exec {BACKUPS_LOG_STDOUT_FD}>&-
	[[ $BACKUPS_LOG_STDOUT_PID -ge 0 ]] && wait ${BACKUPS_LOG_STDOUT_PID}
	[[ -p "${BACKUPS_LOG_STDOUT_FIFO}" ]] && rm ${BACKUPS_LOG_STDOUT_FIFO}
	BACKUPS_LOG_STDOUT_PID=-1

	[[ $BACKUPS_LOG_STDERR_PID -ge 0 ]] && exec {BACKUPS_LOG_STDERR_FD}>&-
	[[ $BACKUPS_LOG_STDERR_PID -ge 0 ]] && wait ${BACKUPS_LOG_STDERR_PID}
	[[ -p "${BACKUPS_LOG_STDERR_FIFO}" ]] && rm ${BACKUPS_LOG_STDERR_FIFO}
	BACKUPS_LOG_STDERR_PID=-1

	trap - SIGINT SIGTERM ERR EXIT
}

function backups::log::start_watchers {
	trap backups::log::teardown SIGINT SIGTERM ERR EXIT
	backups::log::watch_stdout
	backups::log::watch_stderr
}

function backups::log::log_file {
	echo "${BACKUPS_LOG_FILE}"
}

declare -r BACKUPS_LOG_SOURCED=1

# vim: filetype=sh ts=4 sts=4 sw=4 noet
