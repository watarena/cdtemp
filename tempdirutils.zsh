cdtemp() {
    [ $# -eq 0 ] && cd $(mktemp -d) || cd "${TMPDIR%/}/$1"
}

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
    _values 'tempdirs' "${tempdirs[@]}"
}

compdef _cdtemp cdtemp
