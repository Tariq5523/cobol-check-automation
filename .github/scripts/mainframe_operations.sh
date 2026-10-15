#!/bin/bash
# mainframe_operations.sh

# Set up Java environment
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH="$JAVA_HOME/bin:$PATH"

# Add Zowe/Node to PATH
export PATH="/usr/lpp/zowe/cli/node/bin:$PATH"

# Check Java availability
java -version

# Set your mainframe username
ZOWE_USERNAME="Z81174"  # Replace with your actual username

# Change to the COBOL Check directory
cd cobolcheck || exit 1

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
`
