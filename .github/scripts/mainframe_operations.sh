#!/bin/bash
# mainframe_operations.sh - runs on z/OS USS via SSH
# Usage: mainframe_operations.sh <MAINFRAME_USERNAME>

# Set up Java environment
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH="$JAVA_HOME/bin:$PATH"

# Add Zowe/Node to PATH
export PATH="/usr/lpp/zowe/cli/node/bin:$PATH"

# Check Java availability
java -version

# Mainframe username passed in by the workflow
ZOWE_USERNAME="${1:-Z81174}"

# Convert username to lowercase for USS path
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Change to COBOL Check directory on USS
cd "/z/${LOWERCASE_USERNAME}/cobolcheck" || {
    echo "ERROR: cobolcheck directory not found"
    exit 1
}

echo "Changed to $(pwd)"
ls -al

# Make COBOL Check executable
chmod +x cobolcheck
echo "Made cobolcheck executable"

# Make test runner executable
chmod +x scripts/linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"

# Function to run COBOL Check
run_cobolcheck() {
    program="$1"

    echo "========================================"
    echo "Running COBOL Check for $program"
    echo "========================================"

    # Run COBOL Check
    # Do not stop the script yet if COBOL Check returns non-zero
    ./cobolcheck -p "$program" || true

    echo "COBOL Check execution completed for $program"

    # COBOL Check 0.2.19 generates the COBOL test program here
    GENERATED_COBOL="testruns/CC##99.CBL"

    # Copy generated COBOL program into the CBL dataset
    if [ -f "$GENERATED_COBOL" ]; then

        echo "Generated $GENERATED_COBOL found"

        if cp "$GENERATED_COBOL" "//'${ZOWE_USERNAME}.CBL(${program})'"; then
            echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
        else
            echo "ERROR: Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
        fi

    else
        echo "ERROR: $GENERATED_COBOL not found for $program"
    fi

    # Copy JCL into the JCL dataset
    if [ -f "${program}.JCL" ]; then

        echo "${program}.JCL found"

        if cp "${program}.JCL" "//'${ZOWE_USERNAME}.JCL(${program})'"; then
            echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
        else
            echo "ERROR: Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
        fi

    else
        echo "ERROR: ${program}.JCL not found"
    fi
}

# LAB 1: Run NUMBERS only
run_cobolcheck NUMBERS

echo "Mainframe operations completed"
