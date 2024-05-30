#!/bin/bash

OUTPUT_CSV="vmware_lockdown_mode_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-010"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="4. 접근 통제"
evaluationItem="하이퍼바이저 잠금 모드(Lockdown mode) 미설정"
riskLevel="4"
detailedDescription="하이퍼바이저에 대한 잠금 모드가 설정되어 있지 않을 경우 비인가자의 접속으로 인해 하이퍼바이저 및 가상머신 설정 변경, 수정·삭제 등의 침해 위협이 발생 될 수 있으므로, 잠금 모드 설정 여부를 점검"
objectOfEvaluation_vCenter="-"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="-"
judgmentCriteria_vCenter="-"
judgmentMethod_ESXi="1. (방법) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"관리\" > \"보안 및 사용자\" -> \"잠금 모드\" > 잠금모드 설정을 확인"
judgmentCriteria_ESXi="* 양호: 하이퍼바이저 잠금 모드(Lockdown Mode)가 설정되어 있을 경우
* 취약: 하이퍼바이저 잠금 모드(Lockdown Mode)가 설정되어 있지 않은 경우

※ 단, 접속 가능한 단말을 ESXi에서 제공하는 ACL 기능을 통해 통제하고 있을 경우 양호"

# Function to check ESXi lockdown mode
check_esxi() {
    local result=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view /Security/Host/Lockdown/Mode')
    if [[ $result == *"true"* ]]; then
        diagnosisResult="ESXi 하이퍼바이저 잠금 모드(Lockdown Mode)가 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi 하이퍼바이저 잠금 모드(Lockdown Mode)가 설정되어 있지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Perform check
check_esxi

# Display results
cat $OUTPUT_CSV
