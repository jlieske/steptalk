BEGIN {

}

($0 !~ /^[\t ]*#.*$/) && ($0 !~ /^[\t ]*$/) && (NF == 2) {

    printf "    ADD_%s_OBJECT(%s,@\"%s\");\n", $1, $2, $2

}

END {
    printf("    return dict;\n}\n");
}
