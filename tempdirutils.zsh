cdtemp() {
    local tempdir
    if [ $# -eq 0 ]; then
        if tempdir=$(! mktemp -d); then
            return 1
        fi
    else
        tempdir="${TMPDIR%/}/$1"
    fi
    cd "${tempdir}"
}

rmtemp() (
    cd "${TMPDIR}" || return 1

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
    cp -r -- "${TMPDIR%/}/$1/$2" "$3"
}

exectemp() (
    cd "${TMPDIR%/}/$1" || return 1
    shift
    exec "$@"
)

__list_tempdirs() {
    local tempdirs tempdir_values dir dirname
    tempdirs=( "${TMPDIR%/}"/tmp.*/ )
    tempdir_values=()
    for dir in $tempdirs; do
        dir="${dir%/}"
        dirname="${dir##${TMPDIR%/}/}"
        if [ "${words[(Ie)${dirname}]}" -ne 0 ]; then
            continue
        fi
        files=( "${dir}/"*(N) )
        files="${files//${dir}\//}"
        tempdir_values+=( "${dirname}[${files//]/\\]}]" )
    done
    if [ "${#tempdir_values}" -gt 0 ]; then
        _values 'tempdirs' $tempdir_values
    fi
}

_cdtemp() {
    _arguments "1:tempdirs:__list_tempdirs"
}

_rmtemp() {
    _arguments -A '-*' '(-e --empty)'{-e,--empty}'[remove all empty temp dirs]' "*:tempdirs:__list_tempdirs"
}

_cptemp() {
    _arguments "1:tempdirs:__list_tempdirs" "2:src_files:_path_files -W '${TMPDIR%/}/${words[2]}'" '3:dst:_files'
}

_exectemp() {
    _arguments "1:tempdirs:__list_tempdirs" '2:command:_command_names' "*:src_files:_path_files -W '${TMPDIR%/}/${words[2]}'"
}

compdef _cdtemp cdtemp
compdef _rmtemp rmtemp
compdef _cptemp cptemp
compdef _exectemp exectemp
