cdtemp() {
    [ $# -eq 0 ] && cd $(mktemp -d) || cd ${TMPDIR}$1
}

_cdtemp() {
    eval _values 'tempdirs' $(ls -F ${TMPDIR} | grep 'tmp\..*/' | xargs -I{} sh -c 'echo "{}[$(ls ${TMPDIR}{} | xargs)]"' | sed "s/^.*$/'&'/" | tr '\n' ' ')
}

compdef _cdtemp cdtemp
