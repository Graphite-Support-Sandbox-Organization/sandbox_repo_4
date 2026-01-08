#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <feature-name> <stack-count> <stack-height>"
    exit 1
fi

feature_name=$1
stack_count=$2
stack_height=$3

# Function to generate random text
generate_random_text() {
    local words=("lorem" "ipsum" "dolor" "sit" "amet" "consectetur" "adipiscing" "elit"
        "sed" "do" "eiusmod" "tempor" "incididunt" "ut" "labore" "et" "dolore"
        "magna" "aliqua" "enim" "ad" "minim" "veniam" "quis" "nostrud" "exercitation")

    local text=""
    local word_count=$((RANDOM % 20 + 10)) # Generate between 10-30 words

    for ((i = 0; i < word_count; i++)); do
        local rand_index=$((RANDOM % ${#words[@]}))
        text+="${words[$rand_index]} "
    done

    echo "$text"
}

gt checkout main

# Create feature directory if it doesn't exist
for ((stack = 1; stack <= stack_count; stack++)); do
    stack_dir="${feature_name}/${stack}"
    mkdir -p "$stack_dir"

    # For each stack, create 3 iterations
    for ((iter = 1; iter <= stack_height; iter++)); do
        # Generate MD file with random content
        md_file="${stack_dir}/file${iter}.md"
        echo "# Content for Stack ${stack}, Iteration ${iter}" >"$md_file"
        generate_random_text >>"$md_file"

        # Add and commit changes using gt
        gt create --all -m "${feature_name} (Stack #${stack} of ${stack_count}, PR #${iter} of ${stack_height})"
    done

    # Return to main branch after each stack
    gt ss -p --no-interactive # publish, no confirm screen
    sleep 10s
    gt checkout main
done
