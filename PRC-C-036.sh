#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-036"
riskLevel="4"
diagnosisItem="컨테이너 내 CRI socket 불륨 마운트"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-036"
diagnosisItem="컨테이너 내 CRI socket 불륨 마운트"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'volumeMounts'에 CRI Socket 볼륨(docker.sock, containerd.sock 등)이 마운트 되어 있지 않은 경우
[취약]: 'volumeMounts'에 CRI Socket 볼륨(docker.sock, containerd.sock 등)이 마운트 되어 있는 경우
EOF

BAR

# Function to check if the CRI Socket is mounted in containers
check_cri_socket_mount() {
    # Retrieve the volume mounts for each pod/container
    cri_socket_mounts=$(kubectl get pod --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{" : "}{range .spec.volumes[*]}{.name}{" "}{end}{"\n"}{end}')

    # Check each container's volume mounts for CRI socket volume mounts
    while IFS= read -r line; do
        pod_name=$(echo "$line" | cut -d' ' -f1)
        volumes=$(echo "$line" | cut -d':' -f2)

        if [[ "$volumes" =~ "/var/run/docker.sock" ]] || [[ "$volumes" =~ "/run/containerd/containerd.sock" ]]; then
            diagnosisResult="CRI Socket 볼륨이 마운트 되어 있음."
            status="취약"
        else
            diagnosisResult="CRI Socket 볼륨이 마운트 되어 있지 않음."
            status="양호"
        fi

        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    done <<< "$cri_socket_mounts"
}

# Checking for CRI Socket volume mounts
check_cri_socket_mount

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
