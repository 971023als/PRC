#!/bin/bash

OUTPUT_CSV="vmware_ip_access_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-009"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="4. 접근 통제"
evaluationItem="관리 용도 외 IP 접근 미제한"
riskLevel="4"
detailedDescription="관리 목적 이외의 IP에 대한 시스템 접근을 허용하고 있을 경우, 비인가자의 접근으로 인한 침해 위협이 발생 될 수 있으므로 관리 목적의 IP에 대해서만 시스템을 접근할 수 있도록 제한하고 있는지를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="* 아래 방법을 통해 관리 용도 외 IP 접근 제한 여부를 확인

1. 방화벽, iptables 정책 확인 후, 관리 목적 외 IP에서 접근 가능 여부를 확인"
judgmentCriteria_vCenter="* 양호: 관리용도로 허용된 IP 외 접근 가능하지 않은 경우
* 취약: 관리용도로 허용된 IP 외 접근 가능할 경우"
judgmentMethod_ESXi="* 아래 방법을 통해 관리 용도 외 IP 접근 제한 여부를 확인

1. 방화벽, iptables 정책 확인 후, 관리 목적 외 IP에서 접근 가능 여부를 확인"
judgmentCriteria_ESXi="* 양호: 관리용도로 허용된 IP 외 접근 가능하지 않은 경우
* 취약: 관리용도로 허용된 IP 외 접근 가능할 경우"

# Function to check vCenter IP access control
check_vcenter() {
    local result=$(ssh root@vcenter 'iptables -L INPUT -v -n | grep "ACCEPT"')
    if [[ $result == *"ACCEPT"* ]]; then
        diagnosisResult="vCenter 방화벽 정책에 관리 목적 외 IP 접근이 허용되지 않습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="vCenter 방화벽 정책에 관리 목적 외 IP 접근이 허용되고 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi IP access control
check_esxi() {
    local result=$(ssh root@esxi 'iptables -L INPUT -v -n | grep "ACCEPT"')
    if [[ $result == *"ACCEPT"* ]]; then
        diagnosisResult="ESXi 방화벽 정책에 관리 목적 외 IP 접근이 허용되지 않습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi 방화벽 정책에 관리 목적 외 IP 접근이 허용되고 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Perform checks
check_vcenter
check_esxi

# Display results
cat $OUTPUT_CSV
