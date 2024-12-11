#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-035"
riskLevel="4"
diagnosisItem="컨테이너 내 시스템 디렉터리 마운트"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-035"
diagnosisItem="컨테이너 내 시스템 디렉터리 마운트"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 시스템 디렉터리가 마운트 되어 있지 않은 경우
[취약]: 시스템 디렉터리가 마운트 되어 있는 경우
EOF

BAR

# List of critical system directories
system_directories=("/boot" "/dev" "/etc" "/lib" "/proc" "/sys" "/usr")

# Function to check if any system directory is mounted as a volume in containers
check_system_directory_mount() {
    # Retrieve the volume mounts for each pod/container
    system_mounts=$(kubectl get pod --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{" : "}{range .spec.volumes[*]}{.name}{" "}{end}{"\n"}{end}')

    # Check each container's volume mounts for system directories
    while IFS= read -r line; do
        pod_name=$(echo "$line" | cut -d' ' -f1)
        volumes=$(echo "$line" | cut -d':' -f2)

        # Check for system directory mounts
        vulnerability_found=false
        for dir in "${system_directories[@]}"; do
            if [[ "$volumes" =~ "$dir" ]]; then
                vulnerability_found=true
                break
            fi
        done

        if [ "$vulnerability_found" = true ]; then
            diagnosisResult="시스템 디렉터리가 마운트 되어 있음."
            status="취약"
        else
            diagnosisResult="시스템 디렉터리가 마운트 되어 있지 않음."
            status="양호"
        fi

        # Write result to CSV
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    done <<< "$system_mounts"
}

# Checking for system directory mounts
check_system_directory_mount

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
