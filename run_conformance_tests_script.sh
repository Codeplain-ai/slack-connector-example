#!/bin/bash

UNRECOVERABLE_ERROR_EXIT_CODE=69

# Check if build folder and conformance tests folder are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <build_folder_name> <conformance_tests_folder>"
  exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

BUILD_FOLDER=$1
CONF_TESTS_FOLDER=$2
CURRENT_DIR=$(pwd)
PYTHON_BUILD_SUBFOLDER="python_conformance_$BUILD_FOLDER"

# Verify environment variables required for Slack interaction
if [ -z "$SLACK_BOT_TOKEN" ]; then
    echo "Error: SLACK_BOT_TOKEN environment variable is not set."
    exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

if [ -z "$SLACK_DM_ID" ]; then
    echo "Error: SLACK_DM_ID environment variable is not set."
    exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

echo "Preparing Conformance Test environment..."

# Setup build subfolder
if [ -d "$PYTHON_BUILD_SUBFOLDER" ]; then
  find "$PYTHON_BUILD_SUBFOLDER" -mindepth 1 -exec rm -rf {} +
else
  mkdir -p "$PYTHON_BUILD_SUBFOLDER"
fi

cp -R "$BUILD_FOLDER"/* "$PYTHON_BUILD_SUBFOLDER"

# Move to subfolder
cd "$PYTHON_BUILD_SUBFOLDER" || exit $UNRECOVERABLE_ERROR_EXIT_CODE

# Setup Virtual Environment
python3 -m venv venv
source venv/bin/activate

# Install requirements
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    pip install slack_sdk python-dotenv
fi

# Run Conformance Tests
echo "Running Conformance Tests from: $CONF_TESTS_FOLDER"
# Conformance tests are run against the actual Slack API
output=$(python3 -m unittest discover -b -s "$CURRENT_DIR/$CONF_TESTS_FOLDER" 2>&1)
exit_code=$?

echo "$output"

# Check if no tests were discovered
if echo "$output" | grep -q "Ran 0 tests in"; then
    echo "Error: No conformance tests discovered."
    exit 1
fi

deactivate
exit $exit_code