#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-030"
riskLevel="5"
diagnosisItem="컨테이너 및 POD에 seccomp 활성화 및 적용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-030"
diagnosisItem="컨테이너 및 POD에 seccomp 활성화 및 적용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: seccomp 프로파일이 적용되어 있는 경우
[취약]: seccomp 프로파일이 비활성화 되어 있거나 'unconfined'로 설정된 경우
EOF

BAR

# Function to check seccomp configuration in Kubernetes Pods
check_kubernetes_seccomp() {
    # Check seccomp setting in individual pods
    kubectl get pod -n [namespace] -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].name}{' | seccompProfile: '}{.spec.securityContext.seccompProfile.type}{' | localhostProfile: '}{.spec.securityContext.seccompProfile.localhostProfile}{'\n'}{end}" > $TMP1

    while read -r line; do
        pod_name=$(echo $line | cut -d ':' -f1)
        container_info=$(echo $line | cut -d ':' -f2)
        seccomp_type=$(echo $container_info | awk -F 'seccompProfile: ' '{print $2}' | cut -d ' ' -f1)

        if [[ "$seccomp_type" == "Unconfined" || -z "$seccomp_type" ]]; then
            diagnosisResult="seccomp 프로파일 비활성화"
            status="취약"
        else
            diagnosisResult="seccomp 프로파일 적용"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$pod_name: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check seccomp settings in Docker containers
check_docker_seccomp() {
    # Check if Docker is using seccomp
    docker info --format '{{ .SecurityOptions }}' | grep -q 'seccomp'
    if [ $? -eq 0 ]; then
        diagnosisResult="seccomp 프로파일 적용"
        status="양호"
    else
        diagnosisResult="seccomp 프로파일 비활성화"
        status="취약"
    fi

    # Output result to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker SecurityOptions: $diagnosisResult" >> $TMP1

    # Check individual containers' seccomp profile
    docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}' > $TMP1

    while read -r line; do
        if [[ "$line" == *"seccomp:unconfined"* ]]; then
            diagnosisResult="seccomp 프로파일 비활성화"
            status="취약"
        else
            diagnosisResult="seccomp 프로파일 적용"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$line: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Run the checks for Kubernetes and Docker
check_kubernetes_seccomp
check_docker_seccomp

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
