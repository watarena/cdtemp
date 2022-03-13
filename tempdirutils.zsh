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
        files="${files//${dir}/}"
        tempdirs+=( "${dir##${TMPDIR%/}/}:\"${files//\"/\\\"}\"" )
    done
}

_cdtemp() {
    local dir files tempdirs
    tempdirs=()
    for dir in "${TMPDIR%/}"/tmp.*/; do
        files=$(echo "${dir}"*(N))
        files="${files//${dir}/}"
        tempdirs+=( "${dir##${TMPDIR%/}/}:\"${files//\"/\\\"}\"" )
    done
    _arguments "1:tempdirs:((${tempdirs}))"
}

_rmtemp() {
    local dir files tempdirs remain_tempdirs
    tempdirs=( "${TMPDIR%/}"/tmp.*/ )
    tempdirs=( ${tempdirs##${TMPDIR%/}/} )
    tempdirs=( ${tempdirs:|words} )
    remain_tempdirs=()
    for dir in $tempdirs; do
        files=$(echo "${TMPDIR%/}/${dir}"*(N))
        files="${files//${dir}/}"
        remain_tempdirs+=( "${dir}:\"${files//\"/\\\"}\"" )
    done
    _arguments "*:tempdirs:((${remain_tempdirs}))"
}

compdef _cdtemp cdtemp
compdef _rmtemp rmtemp

