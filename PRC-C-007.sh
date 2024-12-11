#!/bin/bash

# Initialize output file
OUTPUT_CSV="output_permissions.csv"
TMP1=$(basename "$0").log

# Define the list of important configuration files and their expected permissions
declare -A config_files=(
    ["kube-apiserver.yaml"]="600"
    ["kube-controller-manager.yaml"]="600"
    ["kube-scheduler.yaml"]="600"
    ["etcd.yaml"]="600"
    ["admin.conf"]="600"
    ["scheduler.conf"]="600"
    ["controller-manager.conf"]="600"
    ["kubeadm.conf"]="600"
    ["kubelet.conf"]="600"
    ["config.yaml"]="600"
    ["daemon.json"]="644"
)

# Create CSV header if file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-007"
riskLevel="3"
diagnosisItem="시스템 주요 설정파일(디렉터리)의 권한 설정 미흡"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Begin checking the permissions of each critical configuration file
for file in "${!config_files[@]}"; do
    expected_permission=${config_files[$file]}

    # Check if the file exists
    if [ -f "$file" ]; then
        current_permission=$(stat -c %a "$file")
        owner_group=$(stat -c %U:%G "$file")

        # Check if the current permission matches the expected permission
        if [ "$current_permission" == "$expected_permission" ]; then
            diagnosisResult="권한이 적절함"
            status="양호"
        else
            diagnosisResult="권한 설정이 부적절함"
            status="취약"
        fi

        # Log the result to the CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "파일: $file, 권한: $current_permission, 소유자: $owner_group" >> $TMP1
    else
        diagnosisResult="파일이 존재하지 않음"
        status="취약"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "파일: $file, 권한 설정 실패: 파일이 존재하지 않음" >> $TMP1
    fi
done

# Output results to terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
