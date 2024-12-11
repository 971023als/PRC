#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-041"
riskLevel="3"
diagnosisItem="호스트의 사용자 네임스페이스 공유"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-041"
diagnosisItem="호스트의 사용자 네임스페이스 공유"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'userns-remap' 설정이 활성화되어 있고, 모든 컨테이너에서 UsernsMode가 'host'가 아닌 경우
[취약]: 'UsernsMode'가 'host'로 설정된 컨테이너가 존재할 경우, 'userns-remap' 설정이 없고, 'UsernsMode'가 'host' 또는 'default'로 설정되어 있는 컨테이너가 존재할 경우
EOF

BAR

# Function to check UsernsMode setting for Docker containers
check_docker_userns_mode() {
    container_id=$1

    # Retrieve UsernsMode configuration from the container's HostConfig
    userns_mode=$(docker inspect --format '{{ .Id }}: UsernsMode={{ .HostConfig.UsernsMode }}' $container_id)

    # Check if UsernsMode is set to host (container shares the host's user namespace)
    if [[ "$userns_mode" =~ "UsernsMode=host" || "$userns_mode" =~ "UsernsMode=default" ]]; then
        diagnosisResult="Container $container_id shares the host's user namespace."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Container $container_id does not share the host's user namespace."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking UsernsMode setting for Docker containers
docker_containers=$(docker ps --quiet --all)

for container_id in $docker_containers; do
    check_docker_userns_mode $container_id
done

# Check if userns-remap is enabled
check_userns_remap() {
    security_options=$(docker info --format '{{ .SecurityOptions }}')

    if [[ "$security_options" =~ "name=userns" ]]; then
        userns_remap="활성화됨"
    else
        userns_remap="비활성화됨"
    fi

    echo "userns-remap 설정: $userns_remap" >> $TMP1
}

# Checking userns-remap configuration
check_userns_remap

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
