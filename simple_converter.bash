#!/usr/bin/env bash

function add_definition() {
    while true; do
        echo "Enter a definition:"
        read -r -a user_input
        
        length="${#user_input[@]}"
        definition="${user_input[0]}"
        constant="${user_input[1]}"
        re_def='^[A-Za-z]+_to_[A-Za-z]+$'
        re_con='^[+-]?[0-9]+\.?[0-9]*$'

        if [ "$length" -ne 2 ]; then
            echo "The definition is incorrect!"
            continue
        elif [[ "$definition" =~ $re_def ]] && [[ "$constant" =~ $re_con ]]; then
            echo "$definition $constant" >> definitions.txt
            break
        else
            echo "The definition is incorrect!"
            continue
        fi
    done
}

function del_definition() {
    line_count=$(wc -l definitions.txt | cut -d " " -f 1)
    if [ "$line_count" -eq 0 ]; then
        echo "Please add a definition first!"
        return
    fi
    echo "Type the line number to delete or '0' to return"
    nl -w1 -s'. ' definitions.txt
    while true; do
        read -r line_num
        re_valid='^[0-9]+$'
        if [[ ! "$line_num" =~ $re_valid ]]; then
            echo "Enter a valid line number!"
            continue
        elif [ "$line_num" -eq 0 ]; then
            return
        elif [ "$line_num" -gt "$line_count" ]; then
            echo "Enter a valid line number!"
            continue
        fi
        sed -i "${line_num}d" "definitions.txt"
        break
    done
}

function convert() {
    line_count=$(wc -l definitions.txt | cut -d " " -f 1)
    if [ "$line_count" -eq 0 ]; then
        echo "Please add a definition first!"
        return
    fi
    echo "Type the line number to convert units or '0' to return"
    nl -w1 -s'. ' definitions.txt
    while true; do
        read -r line_num
        re_valid='^[0-9]+$'
        re_con='[+-]?[0-9]+\.?[0-9]*$'
        if [[ ! "$line_num" =~ $re_valid ]]; then
            echo "Enter a valid line number!"
            continue
        elif [ "$line_num" -eq 0 ]; then
            return
        elif [ "$line_num" -gt "$line_count" ]; then
            echo "Enter a valid line number!"
            continue
        fi
        line=$(sed "${line_num}!d" "definitions.txt")
        read -r -a text <<< $line
        constant="${text[1]}"

        echo "Enter a value to convert:"
        read -r value
        re_con='^[+-]?[0-9]+\.?[0-9]*$'
    
        until [[ "$value" =~ $re_con ]]; do
            echo "Enter a float or integer value!"
            read -r value
        done
        solution=$(echo "scale=2; $constant * $value" | bc -l)
        echo "Result: $solution"
        break
    done
}


touch definitions.txt
echo "Welcome to the Simple converter!"

while true; do
    echo "Select an option"
    echo "0. Type '0' or 'quit' to end program"
    echo "1. Convert units"
    echo "2. Add a definition"
    echo "3. Delete a definition"

    read -r option
    case "$option" in
        0 | 'quit')
            echo "Goodbye!"
            break;;
        1)
            convert;;
        2)
            add_definition;;
        3)
            del_definition;;
        *)
            echo "Invalid option!"
            continue;;
    esac
done
