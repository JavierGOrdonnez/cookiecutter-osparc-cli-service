#!/bin/bash
# set sh strict mode
set -o errexit
set -o nounset
IFS=$(printf '\n\t')

mkdir /home/scu/run
cd /home/scu/run

echo "starting service as"
echo   User    : "$(id "$(whoami)")"
echo   Workdir : "$(pwd)"
echo "..."
echo

# Sanity check: list the files available as inputs, if any
echo "Files in input folder..."
ls -al "${INPUT_FOLDER}"

# Copy input files to current working directory
cp "${INPUT_FOLDER}"/* .

echo "--------------------------------"

# Strip any surrounding quotes from INPUT_1 command if they exist
COMMAND=$(echo "${INPUT_1}" | sed -e 's/^"//' -e 's/"$//')

# This is the command that will be executed
echo "executing command: ${COMMAND}"
eval "${COMMAND}"

echo "---------------------------------"
echo "execution completed, processing outputs..."

# Check which files are created by the execution (i.e. all files in the current dir that are not in INPUT_FOLDER)
# Put all those files in a zip
# If no output file is generate, exit error
files=$(find . -maxdepth 1 -type f ! -exec test -e "${INPUT_FOLDER}"/{} \; -print)

if [ -n "$files" ]; then
    echo "$files" | zip "${OUTPUT_FOLDER}"/output_data.zip -@
else
    echo "Error: No output file were generated." >&2
    exit 1
fi
