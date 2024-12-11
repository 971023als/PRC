#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-022"
riskLevel="2"
diagnosisItem="레지스트리 연결 구간에 대한 보안 프로토콜 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-022"
diagnosisItem="레지스트리 연결 구간에 대한 보안 프로토콜 사용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Insecure Registry가 사용되지 않거나, 레지스트리가 https만 제공하는 경우
[취약]: Insecure Registry가 사용되는 경우
EOF

BAR

# Function to check if Docker is using Insecure Registries
check_insecure_registry() {
    # Check if the docker daemon is using insecure registries (via dockerd command line)
    ps -ef | grep 'dockerd' | grep -- 'insecure-registry' > $TMP1
    if [ $? -eq 0 ]; then
        insecure_registry=$(ps -ef | grep 'dockerd' | grep 'insecure-registry' | awk -F '--insecure-registry=' '{print $2}' | sed 's/^[[:space:]]*//')
        diagnosisResult="Insecure Registry 사용됨: $insecure_registry"
        status="취약"
    else
        # Check docker configuration file for insecure-registries setting
        sudo cat /etc/docker/daemon.json | grep "insecure-registries" > $TMP1
        if [ $? -eq 0 ]; then
            insecure_registry=$(sudo cat /etc/docker/daemon.json | grep "insecure-registries" | awk -F ': ' '{print $2}' | sed 's/[",]//g')
            diagnosisResult="Insecure Registry 사용됨: $insecure_registry"
            status="취약"
        else
            # Check Docker info for insecure registries
            insecure_registry_info=$(docker info --format 'Insecure Registries: {{.RegistryConfig.InsecureRegistryCIDRs}}')
            if [[ "$insecure_registry_info" == *"localhost"* ]] || [[ "$insecure_registry_info" == *"127.0.0.1"* ]] || [[ "$insecure_registry_info" == *"https"* ]]; then
                diagnosisResult="Insecure Registry 사용되지 않음"
                status="양호"
            else
                diagnosisResult="Insecure Registry 사용됨: $insecure_registry_info"
                status="취약"
            fi
        fi
    fi

    # Output result for Insecure Registry check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Insecure Registry Check: $diagnosisResult" >> $TMP1
}

# Run the check for insecure registry usage
check_insecure_registry

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
