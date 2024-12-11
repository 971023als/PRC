#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-046"
riskLevel="4"
diagnosisItem="HostPort 사용 컨테이너의 허용 최소화"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-046"
diagnosisItem="HostPort 사용 컨테이너의 허용 최소화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 hostPort가 존재하지 않는 경우
[취약]: 불필요한 hostPort가 존재하는 경우
EOF

BAR

# Function to check hostPort usage in Kubernetes Pods
check_hostport_k8s() {
    local pod_name=$1
    local namespace=$2

    # Retrieve hostPort usage from the pod container specifications
    host_ports=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{range .spec.containers[*]}{.name}|{range .ports[*]}{.name}:{.containerPort}:{.hostPort}:{.protocol};{end}{end}")

    # Check if any container in the pod has a hostPort set
    if [[ "$host_ports" =~ ":0:" ]]; then
        diagnosisResult="Pod $pod_name in namespace $namespace has unnecessary hostPort exposure."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Pod $pod_name in namespace $namespace has no unnecessary hostPort exposure."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking hostPort usage for Kubernetes pods
pods=$(kubectl get pods --all-namespaces --no-headers | grep -v "kube-system" | awk '{print $1 " " $2}')

for pod in $pods; do
    pod_name=$(echo $pod | cut -d ' ' -f 1)
    namespace=$(echo $pod | cut -d ' ' -f 2)
    check_hostport_k8s $pod_name $namespace
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
