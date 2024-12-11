#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-029"
riskLevel="4"
diagnosisItem="컨테이너의 권한 통제 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-029"
diagnosisItem="컨테이너의 권한 통제 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'allowPrivilegeEscalation'가 false로 설정된 경우, 'no-new-privileges'가 true로 설정된 경우
[취약]: 'allowPrivilegeEscalation'가 없거나 true로 설정된 경우, 'no-new-privileges'가 false로 설정된 경우
EOF

BAR

# Function to check allowPrivilegeEscalation in Kubernetes Pods
check_kubernetes_privilege_escalation() {
    kubectl get pod -n [namespace] -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].name}{' | allowPrivilegeEscalation: '}{.spec.securityContext.allowPrivilegeEscalation}{'\n'}{end}" > $TMP1

    while read -r line; do
        pod_name=$(echo $line | cut -d ':' -f1)
        container_info=$(echo $line | cut -d ':' -f2)
        allow_priv_esc=$(echo $container_info | awk -F 'allowPrivilegeEscalation: ' '{print $2}' | cut -d ' ' -f1)

        if [[ "$allow_priv_esc" == "false" ]]; then
            diagnosisResult="allowPrivilegeEscalation 설정이 false"
            status="양호"
        else
            diagnosisResult="allowPrivilegeEscalation 설정이 true 또는 미설정"
            status="취약"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$pod_name: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check 'no-new-privileges' in Docker
check_docker_no_new_privileges() {
    # Check Docker daemon for 'no-new-privileges' flag
    ps -ef | grep 'dockerd' | grep -q "no-new-privileges"
    if [ $? -eq 0 ]; then
        diagnosisResult="'no-new-privileges' 설정이 true"
        status="양호"
    else
        diagnosisResult="'no-new-privileges' 설정이 false"
        status="취약"
    fi

    # Output result to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker daemon no-new-privileges: $diagnosisResult" >> $TMP1

    # Check individual containers' 'no-new-privileges' setting
    docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}' > $TMP1

    while read -r line; do
        if [[ "$line" == *"no-new-privileges=false"* ]]; then
            diagnosisResult="'no-new-privileges' 설정이 false"
            status="취약"
        else
            diagnosisResult="'no-new-privileges' 설정이 true"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$line: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check Docker configuration for 'no-new-privileges'
check_docker_daemon_json() {
    sudo cat /etc/docker/daemon.json | grep -q "no-new-privileges"
    if [ $? -eq 0 ]; then
        diagnosisResult="'no-new-privileges' 설정이 true"
        status="양호"
    else
        diagnosisResult="'no-new-privileges' 설정이 false"
        status="취약"
    fi

    # Output result to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker daemon.json no-new-privileges: $diagnosisResult" >> $TMP1
}

# Run the checks for Kubernetes and Docker
check_kubernetes_privilege_escalation
check_docker_no_new_privileges
check_docker_daemon_json

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
