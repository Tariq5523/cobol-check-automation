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

# Mainframe username (passed in by the workflow; defaults to Z81174)
ZOWE_USERNAME="${1:-Z81174}"
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Change to the COBOL Check directory (absolute path, not dependent on login dir)
cd "/z/${LOWERCASE_USERNAME}/cobolcheck" || { echo "ERROR: cobolcheck directory not found"; exit 1; }

echo "Changed to $(pwd)"
ls -al

# Make COBOL Check executable
chmod +x cobolcheck
echo "Made cobolcheck executable"

# Make test runner executable
chmod +x scripts/linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"

# Function to run COBOL Check and copy generated files
run_cobolcheck() {
    program="$1"

    echo "Running COBOL Check for $program"

    # Run COBOL Check
    # Continue processing even if COBOL Check returns a non-zero status
    ./cobolcheck -p "$program"

    echo "COBOL Check execution completed for $program"

    # Copy generated COBOL file to MVS dataset
    if [ -f "CC##99.CBL" ]; then
        if cp "CC##99.CBL" "//'${ZOWE_USERNAME}.CBL(${program})'"; then
            echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
        else
            echo "Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
        fi
    else
        echo "CC##99.CBL not found for $program"
    fi

    # Copy generated JCL file to MVS dataset
    if [ -f "${program}.JCL" ]; then
        if cp "${program}.JCL" "//'${ZOWE_USERNAME}.JCL(${program})'"; then
            echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
        else
            echo "Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
        fi
    else
        echo "${program}.JCL not found"
    fi
}

# Run COBOL Check for each program
for program in NUMBERS EMPPAY DEPTPAY; do
    run_cobolcheck "$program"
done

echo "Mainframe operations completed"
