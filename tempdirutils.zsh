cdtemp() {
    [ $# -eq 0 ] && cd $(mktemp -d) || cd "${TMPDIR%/}/$1"
}

rmtemp() (
    cd "${TMPDIR}"
    rm -rf "$@"
)

_list_tempdirs() {
    local dir files
    for dir in "${TMPDIR%/}"/tmp.*/; do
        files=$(echo "${dir}"*(N))
        tempdirs+=( "${dir##${TMPDIR%/}/}[${files//${dir}/}]" )
    done
}

_cdtemp() {
    local tempdirs
    tempdirs=()
    _list_tempdirs
    if [ ${#tempdirs} -gt 0 ]; then
        _values 'tempdirs' "${tempdirs[@]}"
    else
        _values 'tempdirs' ''
    fi
}

_rmtemp() {
    local tempdirs
    tempdirs=()
    _list_tempdirs
    for arg in ${words:1}; do
      tempdirs=( ${tempdirs:#${arg}\[*]} )
    done
    if [ ${#tempdirs} -gt 0 ]; then
        _values 'tempdirs' "${tempdirs[@]}"
    else
        _values 'tempdirs' ''
    fi
}

compdef _cdtemp cdtemp
compdef _rmtemp rmtemp

