#!/bin/bash

UNRECOVERABLE_ERROR_EXIT_CODE=69

# Check if project folder name is provided
if [ -z "$1" ]; then
  echo "Error: No project folder name provided."
  echo "Usage: $0 <project_folder_name>"
  exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

PROJECT_FOLDER=$1
PYTHON_BUILD_SUBFOLDER=".tmp/$1"

echo "Preparing Python environment in: $PYTHON_BUILD_SUBFOLDER"

# Clean up or create the build subfolder
if [ -d "$PYTHON_BUILD_SUBFOLDER" ]; then
  find "$PYTHON_BUILD_SUBFOLDER" -mindepth 1 -exec rm -rf {} +
else
  mkdir -p "$PYTHON_BUILD_SUBFOLDER"
fi

# Copy project files
cp -R "$PROJECT_FOLDER"/* "$PYTHON_BUILD_SUBFOLDER"

# Move to the subfolder
cd "$PYTHON_BUILD_SUBFOLDER" || exit $UNRECOVERABLE_ERROR_EXIT_CODE

# Setup Virtual Environment
echo "Creating and activating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install requirements
if [ -f "requirements.txt" ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
else
    echo "Warning: requirements.txt not found. Installing default dependencies..."
    pip install slack_sdk python-dotenv
fi

# Execute Python unittests
echo "Running Python unittests..."
# Using -b to buffer stdout/stderr and -v for verbosity
output=$(timeout 120s python3 -m unittest discover -b -v 2>&1)
exit_code=$?

# Check for timeout
if [ $exit_code -eq 124 ]; then
    echo "Error: Unittests timed out after 120 seconds."
    exit $exit_code
fi

echo "$output"

# Deactivate venv
deactivate

exit $exit_code