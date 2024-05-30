#!/bin/bash

OUTPUT_CSV="vmware_exception_user_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-008"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="3. 인증 정책 설정"
evaluationItem="예외 사용자 목록 내 불필요한 사용자 존재"
riskLevel="4"
detailedDescription="예외 사용자 목록 내 불필요한 사용자가 존재할 경우 비인가자에 의해 시스템 무단 침입을 할 수 있으므로, 예외 사용자 목록 내 불필요한 사용자 존재 여부를 점검"
objectOfEvaluation_vCenter="-"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="-"
judgmentCriteria_vCenter="-"
judgmentMethod_ESXi="1. (방법) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"관리\" > \"보안 및 사용자\" -> \"잠금 모드\" > 예외 사용자 목록 확인"
judgmentCriteria_ESXi="* 양호: 잠금 모드(Lockdown mode)를 사용하고 있고, 불필요한 사용자 없이 최소한의 사용자만 예외 사용자 목록에 추가되어 있을 경우
* 취약: 잠금 모드(Lockdown mode)를 사용하지 않거나, 예외 사용자 목록에 불필요한 사용자가 존재할 경우

※ 단, 접속 가능한 단말을 ESXi에서 제공하는 ACL 기능을 통해 통제하고 있을 경우 양호"

# Function to check ESXi exception user list
check_esxi() {
    local exception_users=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view /Security/Host/Lockdown/ExceptionUsers')
    local lockdown_mode=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view /Security/Host/Lockdown/Mode')
    
    if [[ $lockdown_mode == *"true"* ]]; then
        if [[ $exception_users == *"root"* ]]; then
            diagnosisResult="ESXi 잠금 모드를 사용하고 있으며, 예외 사용자 목록에 불필요한 사용자가 존재하지 않습니다."
            status="양호"
            echo "OK: $diagnosisResult"
        else
            diagnosisResult="ESXi 예외 사용자 목록에 불필요한 사용자가 존재합니다."
            status="취약"
            echo "WARN: $diagnosisResult"
        fi
    else
        diagnosisResult="ESXi 잠금 모드를 사용하지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Perform check
check_esxi

# Display results
cat $OUTPUT_CSV
