#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-045"
riskLevel="3"
diagnosisItem="컨테이너의 호스트 UTS 네임스페이스 공유 최소화"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-045"
diagnosisItem="컨테이너의 호스트 UTS 네임스페이스 공유 최소화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'hostUTS'가 'false'로 설정되어 있는 경우
[취약]: 'hostUTS'가 'true'로 설정되어 있는 경우
EOF

BAR

# Function to check UTS namespace sharing in Kubernetes Pods
check_uts_k8s() {
    local pod_name=$1
    local namespace=$2

    # Retrieve UTS sharing configuration from the pod container specifications
    uts_sharing=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{range .spec.containers[*]}{.name}|securityContext.hostUTS:'{.securityContext.hostUTS}'{end}")

    # Check if hostUTS is set to true (container shares the host's UTS namespace)
    if [[ "$uts_sharing" =~ "true" ]]; then
        diagnosisResult="Pod $pod_name in namespace $namespace shares the host's UTS namespace."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Pod $pod_name in namespace $namespace does not share the host's UTS namespace."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking UTS namespace sharing for Kubernetes pods
pods=$(kubectl get pods --all-namespaces --no-headers | grep -v "kube-system" | awk '{print $1 " " $2}')

for pod in $pods; do
    pod_name=$(echo $pod | cut -d ' ' -f 1)
    namespace=$(echo $pod | cut -d ' ' -f 2)
    check_uts_k8s $pod_name $namespace
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
