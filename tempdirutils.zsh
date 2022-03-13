cdtemp() {
    [ $# -eq 0 ] && cd $(mktemp -d) || cd "${TMPDIR%/}/$1"
}

rmtemp() (
    cd "${TMPDIR}"
    rm -rf "$@"
)

cptemp() {
    cp -r "${TMPDIR%/}/$1/$2" "$3"
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

_cptemp() {
    local dir files tempdirs
    tempdirs=()
    for dir in "${TMPDIR%/}"/tmp.*/; do
        files=$(echo "${dir}"*(N))
        files="${files//${dir}/}"
        tempdirs+=( "${dir##${TMPDIR%/}/}:\"${files//\"/\\\"}\"" )
    done
    _arguments "1:tempdirs:((${tempdirs}))" "2:src_files:_path_files -W '${TMPDIR%/}/${words[2]}'" '3:dst:_files'
}

compdef _cdtemp cdtemp
compdef _rmtemp rmtemp
compdef _cptemp cptemp
