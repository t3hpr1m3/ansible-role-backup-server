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
	backups::config::init
	backups::log::init
}

BACKUPS_CONFIGURATION_FILE="${BACKUPS_CONFIGURATION_FILE:-/etc/backups.json}"

source "${BACKUP_SERVER_LIB}/functions.bash"
source "${BACKUP_SERVER_LIB}/config.bash"
source "${BACKUP_SERVER_LIB}/log.bash"

declare -r BACKUPS_VERSION="0.0.1"

# vim: filetype=sh ts=4 sts=4 sw=4 noet
