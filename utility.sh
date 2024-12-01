#!/bin/bash

list_users() {
    getent passwd | awk -F: '{if ($6 != "" && $6 != "/nonexistent") print $1, $6}' | sort
}

list_processes() {
    ps -eo pid,cmd --sort=pid
}

# Функция для справки
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -u, --users           Display list of users and their home directories."
    echo "  -p, --processes       Display list of running processes sorted by PID."
    echo "  -h, --help            Show this help message."
    echo "  -l PATH, --log PATH   Redirect output to the specified file PATH."
    echo "  -e PATH, --errors PATH Redirect error messages to the specified file PATH."
}

OUTPUT=""
ERRORS=""
ACTION=""

while getopts ":uph-:l:e:" opt; do
    case $opt in
        u)
            ACTION="users"
            ;;
        p)
            ACTION="processes"
            ;;
        h)
            ACTION="help"
            ;;
        l)
            OUTPUT="$OPTARG"
            ;;
        e)
            ERRORS="$OPTARG"
            ;;
        -)
            case $OPTARG in
                users)
                    ACTION="users"
                    ;;
                processes)
                    ACTION="processes"
                    ;;
                help)
                    ACTION="help"
                    ;;
                log)
                    OUTPUT="${!OPTIND}"; OPTIND=$((OPTIND + 1))
                    ;;
                errors)
                    ERRORS="${!OPTIND}"; OPTIND=$((OPTIND + 1))
                    ;;
                *)
                    echo "Invalid option: --$OPTARG" >&2
                    exit 1
                    ;;
            esac
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [[ -n $OUTPUT && ! -w $(dirname "$OUTPUT") ]]; then
    echo "Error: Cannot write to output file path $OUTPUT" >&2
    exit 1
fi

if [[ -n $ERRORS && ! -w $(dirname "$ERRORS") ]]; then
    echo "Error: Cannot write to errors file path $ERRORS" >&2
    exit 1
fi

exec >"$OUTPUT" 2>"$ERRORS"

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
