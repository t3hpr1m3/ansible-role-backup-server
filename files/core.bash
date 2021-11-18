[ -z ${BACKUPS_VERSION+x} ] || return

function backups::getopts {
	echo "-:"
}

function backups::parse_params {
	declare script_args="$1"
	declare -r opts="$(backups::log::opts)$(backups::config::opts)${script_args}$(backups::getopts)"
	shift
	OPTIND=0
	getopts "${opts}" OPT
	declare rc=$?

	while [ $rc -eq 0 ]; do
		if [ "$OPT" = "-" ]; then
			OPT="${OPTARG%%=*}"
			OPTARG="${OPTARG#$OPT}"
			OPTARG="${OPTARG#=}"
		fi

		case "$OPT" in
			* )
				backups::log::parse_param $OPT ${OPTARG:-} ||
				backups::config::parse_param $OPT ${OPTARG:-} || break
				;;
		esac
		getopts "${opts}" OPT
		rc=$?
	done

	return $rc
}

function backups::init {
	return 0
}

function backups::check_pid {
	declare -r pid_file="$1"
	declare -i old_pid=-1

	if [[ -f "${pid_file}" ]]; then
		old_pid=$(cat "${pid_file}")
		if [[ -d "/proc/${old_pid}" ]]; then
			echo "${old_pid}"
		else
			echo "-1"
		fi
	else
		echo "0"
	fi
}

backups::update_pid() {
	declare -r pid_file="$1"
	declare -ri pid="$2"

	echo $pid >$pid_file
}

backups::clear_pid() {
	declare -r pid_file="$1"
	rm ${pid_file}
}

source "${BACKUP_SERVER_LIB}/config.bash"
source "${BACKUP_SERVER_LIB}/json.bash"
source "${BACKUP_SERVER_LIB}/log.bash"
source "${BACKUP_SERVER_LIB}/utils.bash"

declare -r BACKUPS_VERSION="0.0.1"

# vim: filetype=sh ts=4 sts=4 sw=4 noet
