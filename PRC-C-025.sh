#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-025"
riskLevel="2"
diagnosisItem="불필요한 프로파일링 기능 활성화"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-025"
diagnosisItem="불필요한 프로파일링 기능 활성화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: profiling이 false로 설정된 경우
[취약]: profiling이 설정되지 않았거나 true로 설정된 경우
EOF

BAR

# Function to check Kubernetes components for profiling flag
check_kubernetes_profiling() {
    # Check profiling in kube-apiserver
    kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "profiling" > $TMP1
    if [ $? -eq 0 ]; then
        diagnosisResult="profiling 기능 활성화됨"
        status="취약"
    else
        diagnosisResult="profiling 기능 비활성화됨"
        status="양호"
    fi

    # Output result for kube-apiserver
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kube-apiserver: $diagnosisResult" >> $TMP1

    # Check profiling in kube-scheduler
    kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "profiling" >> $TMP1
    if [ $? -eq 0 ]; then
        diagnosisResult="profiling 기능 활성화됨"
        status="취약"
    else
        diagnosisResult="profiling 기능 비활성화됨"
        status="양호"
    fi

    # Output result for kube-scheduler
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kube-scheduler: $diagnosisResult" >> $TMP1

    # Check profiling in kube-controller-manager
    kubectl get pods -n kube-system -l component=kube-controller-manager -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "profiling" >> $TMP1
    if [ $? -eq 0 ]; then
        diagnosisResult="profiling 기능 활성화됨"
        status="취약"
    else
        diagnosisResult="profiling 기능 비활성화됨"
        status="양호"
    fi

    # Output result for kube-controller-manager
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kube-controller-manager: $diagnosisResult" >> $TMP1
}

# Function to check process-level profiling settings
check_process_profiling() {
    # Check if profiling flag is enabled for apiserver, scheduler, or controller-manager processes
    ps -ef | grep -E "apiserver|scheduler|controller-manager" | grep -E "profiling" | grep -v grep > $TMP1
    if [ $? -eq 0 ]; then
        diagnosisResult="profiling 기능 활성화됨"
        status="취약"
    else
        diagnosisResult="profiling 기능 비활성화됨"
        status="양호"
    fi

    # Output result for processes
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Process-level profiling: $diagnosisResult" >> $TMP1
}

# Function to check Kubernetes YAML files for profiling
check_kubernetes_yaml() {
    # Check profiling settings in kube-apiserver.yaml, kube-scheduler.yaml, and kube-controller-manager.yaml
    grep -E "profiling" "/etc/kubernetes/manifests/kube-apiserver.yaml" >> $TMP1
    grep -E "profiling" "/etc/kubernetes/manifests/kube-scheduler.yaml" >> $TMP1
    grep -E "profiling" "/etc/kubernetes/manifests/kube-controller-manager.yaml" >> $TMP1

    if [ $? -eq 0 ]; then
        diagnosisResult="profiling 기능 활성화됨"
        status="취약"
    else
        diagnosisResult="profiling 기능 비활성화됨"
        status="양호"
    fi

    # Output result for YAML files
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "YAML profiling: $diagnosisResult" >> $TMP1
}

# Run all checks
check_kubernetes_profiling
check_process_profiling
check_kubernetes_yaml

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
