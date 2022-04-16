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
    cd "${TMPDIR}"
    rm -rf "$@"
)

cptemp() {
    cp -r "${TMPDIR%/}/$1/$2" "$3"
}

exectemp() (
    cd "${TMPDIR%/}/$1" || return 1
    shift
    exec "$@"
)

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
        dir_path="${TMPDIR%/}/${dir}"
        files=$(echo "${dir_path}"*(N))
        files="${files//${dir_path}/}"
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

_exectemp() {
    local dir files tempdirs
    tempdirs=()
    for dir in "${TMPDIR%/}"/tmp.*/; do
        files=$(echo "${dir}"*(N))
        files="${files//${dir}/}"
        tempdirs+=( "${dir##${TMPDIR%/}/}:\"${files//\"/\\\"}\"" )
    done
    _arguments "1:tempdirs:((${tempdirs}))" '2:command:_command_names' "*:src_files:_path_files -W '${TMPDIR%/}/${words[2]}'"
}

compdef _cdtemp cdtemp
compdef _rmtemp rmtemp
compdef _cptemp cptemp
compdef _exectemp exectemp
