TEMPDIRUTILS_BASEDIR="${TEMPDIRUTILS_BASEDIR:-$TMPDIR}"
TEMPDIRUTILS_TEMPDIR_PREFIX="${TEMPDIRUTILS_TEMPDIR_PREFIX:-tmp.}"

cdtemp() {
    local tempdir
    if [ $# -eq 0 ]; then
        if tempdir=$(! mktemp -d "${TEMPDIRUTILS_BASEDIR%/}/${TEMPDIRUTILS_TEMPDIR_PREFIX}XXXXXXXXXX"); then
            return 1
        fi
    else
        tempdir="${TEMPDIRUTILS_BASEDIR%/}/$1"
    fi
    cd "${tempdir}"
}

rmtemp() (
    cd "${TEMPDIRUTILS_BASEDIR}" || return 1

    local rmdirs=()
    local is_empty_option_specified=false
    while [ $# -ge 0 ]; do
        case "$1" in
        -e|--empty)
            if [ "$is_empty_option_specified" = 'false' ]; then
                rmdirs+=("${(@f)$(find . -maxdepth 1 -type d -name 'tmp.*' -empty)}")
                is_empty_option_specified=true
            fi
            shift
            ;;
        *) break;;
        esac
    done
    rmdirs+=( "$@" )
    rm -rf -- "${rmdirs[@]}"
)

cptemp() {
    cp -r -- "${TEMPDIRUTILS_BASEDIR%/}/$1/$2" "$3"
}

exectemp() (
    cd "${TEMPDIRUTILS_BASEDIR%/}/$1" || return 1
    shift
    exec "$@"
)

__list_tempdirs() {
    local tempdirs tempdir_values dir dirname
    tempdirs=( "${TEMPDIRUTILS_BASEDIR%/}/$TEMPDIRUTILS_TEMPDIR_PREFIX"*/ )
    tempdir_values=()
    for dir in $tempdirs; do
        dir="${dir%/}"
        dirname="${dir##${TEMPDIRUTILS_BASEDIR%/}/}"
        if [ "${words[(Ie)${dirname}]}" -ne 0 ]; then
            continue
        fi
        files=( "${dir}/"*(N) )
        files="${files//${dir}\//}"
        tempdir_values+=( "${dirname}[${files//]/\\]}]" )
    done
    if [ "${#tempdir_values}" -gt 0 ]; then
        _values 'tempdirs' "${tempdir_values[@]}"
    fi
}

_cdtemp() {
    _arguments "1:tempdirs:__list_tempdirs"
}

_rmtemp() {
    _arguments -A '-*' '(-e --empty)'{-e,--empty}'[remove all empty temp dirs]' "*:tempdirs:__list_tempdirs"
}

_cptemp() {
    _arguments "1:tempdirs:__list_tempdirs" "2:src_files:_path_files -W '${TEMPDIRUTILS_BASEDIR%/}/${words[2]}'" '3:dst:_files'
}

_exectemp() {
    _arguments "1:tempdirs:__list_tempdirs" '2:command:_command_names' "*:src_files:_path_files -W '${TEMPDIRUTILS_BASEDIR%/}/${words[2]}'"
}

compdef _cdtemp cdtemp
compdef _rmtemp rmtemp
compdef _cptemp cptemp
compdef _exectemp exectemp
