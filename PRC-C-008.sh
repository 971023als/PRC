#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-008"
riskLevel="4"
diagnosisItem="서비스 바인딩 주소의 적절성"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-008"
diagnosisItem="서비스 바인딩 주소의 적절성"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'bind-address'가 127.0.0.1 또는 신뢰구간에 위치한 IP로 설정되어 있는 경우
[취약]: 'bind-address'가 0.0.0.0으로 설정되어 있는 경우
EOF

BAR

# Function to check bind-address for kube-scheduler and kube-controller-manager
check_service_bind_address() {
    # Check the bind-address for kube-scheduler
    scheduler_bind_address=$(ps -ef | grep scheduler | grep -E "bind-address" | grep -v grep)
    if [[ ! -z "$scheduler_bind_address" ]]; then
        if [[ "$scheduler_bind_address" =~ "bind-address=127.0.0.1" || "$scheduler_bind_address" =~ "bind-address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" ]]; then
            diagnosisResult="bind-address 설정이 적절함"
            status="양호"
        else
            diagnosisResult="bind-address가 0.0.0.0으로 설정됨"
            status="취약"
        fi
    else
        diagnosisResult="bind-address 설정이 없음"
        status="취약"
    fi

    # Output result for kube-scheduler bind-address
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-scheduler bind-address 확인: $diagnosisResult" >> $TMP1

    # Check the bind-address for kube-controller-manager
    controller_manager_bind_address=$(ps -ef | grep controller-manager | grep -E "bind-address" | grep -v grep)
    if [[ ! -z "$controller_manager_bind_address" ]]; then
        if [[ "$controller_manager_bind_address" =~ "bind-address=127.0.0.1" || "$controller_manager_bind_address" =~ "bind-address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" ]]; then
            diagnosisResult="bind-address 설정이 적절함"
            status="양호"
        else
            diagnosisResult="bind-address가 0.0.0.0으로 설정됨"
            status="취약"
        fi
    else
        diagnosisResult="bind-address 설정이 없음"
        status="취약"
    fi

    # Output result for kube-controller-manager bind-address
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-controller-manager bind-address 확인: $diagnosisResult" >> $TMP1
}

# Function to check bind-address in YAML configuration files for kube-scheduler and kube-controller-manager
check_bind_address_in_files() {
    # Check for bind-address in kube-scheduler.yaml
    scheduler_yaml_bind_address=$(grep -E "bind-address" "/etc/kubernetes/manifests/kube-scheduler.yaml")
    if [[ ! -z "$scheduler_yaml_bind_address" ]]; then
        if [[ "$scheduler_yaml_bind_address" =~ "bind-address=127.0.0.1" || "$scheduler_yaml_bind_address" =~ "bind-address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" ]]; then
            diagnosisResult="bind-address 설정이 적절함"
            status="양호"
        else
            diagnosisResult="bind-address가 0.0.0.0으로 설정됨"
            status="취약"
        fi
    else
        diagnosisResult="bind-address 설정이 없음"
        status="취약"
    fi

    # Output result for kube-scheduler bind-address in file
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-scheduler bind-address 설정 확인 (YAML): $diagnosisResult" >> $TMP1

    # Check for bind-address in kube-controller-manager.yaml
    controller_manager_yaml_bind_address=$(grep -E "bind-address" "/etc/kubernetes/manifests/kube-controller-manager.yaml")
    if [[ ! -z "$controller_manager_yaml_bind_address" ]]; then
        if [[ "$controller_manager_yaml_bind_address" =~ "bind-address=127.0.0.1" || "$controller_manager_yaml_bind_address" =~ "bind-address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" ]]; then
            diagnosisResult="bind-address 설정이 적절함"
            status="양호"
        else
            diagnosisResult="bind-address가 0.0.0.0으로 설정됨"
            status="취약"
        fi
    else
        diagnosisResult="bind-address 설정이 없음"
        status="취약"
    fi

    # Output result for kube-controller-manager bind-address in file
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-controller-manager bind-address 설정 확인 (YAML): $diagnosisResult" >> $TMP1
}

# Run checks for bind-address in processes and configuration files for both scheduler and controller-manager
check_service_bind_address
check_bind_address_in_files

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
