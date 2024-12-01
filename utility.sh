#!/bin/bash

list_users() {
    getent passwd | awk -F: '{if ($6 && $6 != "/nonexistent") print $1, $6}' | sort
}

list_processes() {
    ps -eo pid,cmd --sort=pid
}

# Функция для справки
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -u, --users           Display list of users and their home directories.
  -p, --processes       Display list of running processes sorted by PID.
  -h, --help            Show this help message.
  -l PATH, --log PATH   Redirect output to the specified file PATH.
  -e PATH, --errors PATH Redirect error messages to the specified file PATH.
EOF
}


parse_args() {
    local TEMP
    TEMP=$(getopt -o "uph:l:e:" --long "users,processes,help,log:,errors:" -n "$0" -- "$@")
    if [ $? != 0 ]; then
        echo "Error parsing options." >&2
        exit 1
    fi
    eval set -- "$TEMP"

    while true; do
        case "$1" in
            -u|--users)
                ACTION="users"
                shift
                ;;
            -p|--processes)
                ACTION="processes"
                shift
                ;;
            -h|--help)
                ACTION="help"
                shift
                ;;
            -l|--log)
                OUTPUT="$2"
                shift 2
                ;;
            -e|--errors)
                ERRORS="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid option: $1" >&2
                exit 1
                ;;
        esac
    done
}

check_paths() {
    if [[ -n $OUTPUT && ! -w $(dirname "$OUTPUT") ]]; then
        echo "Error: Cannot write to output file path $OUTPUT" >&2
        exit 1
    fi

    if [[ -n $ERRORS && ! -w $(dirname "$ERRORS") ]]; then
        echo "Error: Cannot write to errors file path $ERRORS" >&2
        exit 1
    fi
}

# Замена потоков вывода
redirect_streams() {
    if [[ -n $OUTPUT ]]; then
        exec >"$OUTPUT"
    fi
    if [[ -n $ERRORS ]]; then
        exec 2>"$ERRORS"
    fi
}

main() {
    parse_args "$@"
    check_paths
    redirect_streams

    case $ACTION in
        users)
            list_users
            ;;
        processes)
            list_processes
            ;;
        help)
            show_help
            ;;
        *)
            echo "No valid action specified. Use -h or --help for usage information." >&2
            exit 1
            ;;
    esac
}
main "$@"