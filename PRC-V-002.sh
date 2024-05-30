#!/bin/bash

OUTPUT_CSV="vmware_security_assessment.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-002"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="1. 계정 관리"
evaluationItem="관리자 그룹 내 불필요한 계정 존재"
riskLevel="5"
detailedDescription="다수의 관리자 계정이 존재할 경우 공격자가 탈취를 시도할 수 있는 관리자 계정이 많아지므로 업무상 필요한 최소한의 사용자만 관리자 그룹에 등록하여 사용하고 있는지 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="* 아래 방법을 통해 계정 목록 및 적용 권한 확인

1. (방법1) SSH를 통해 vCenter 접속 후, 다음 명령어 실행 (localos 계정 확인 방법)
Command > com.vmware.appliance.version1.localaccounts.user.list
2. (방법2) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"메뉴\" > \"관리\" > \"사용자 및 그룹\" > \"도메인\" 선택 > 계정정보 확인"
judgmentCriteria_vCenter="* 양호 - 관리자 그룹에 불필요한 관리자 계정이 없을 경우
* 취약 - 관리자 그룹에 불필요한 관리자 계정이 있을 경우"
judgmentMethod_ESXi="1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ vim-cmd vimsvc/auth/permissions
2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"관리\" > \"사용 권한\" > \"역할\" > 관리자 현황 확인"
judgmentCriteria_ESXi="* 양호 - 관리자 그룹에 불필요한 관리자 계정이 없을 경우
* 취약 - 관리자 그룹에 불필요한 관리자 계정이 있을 경우"

# Function to check vCenter
check_vcenter() {
    local result=$(ssh root@vcenter 'com.vmware.appliance.version1.localaccounts.user.list')
    local admin_accounts=$(echo "$result" | grep -E "admin|root|administrator" | wc -l)
    if [ $admin_accounts -le 1 ]; then
        diagnosisResult="관리자 그룹에 불필요한 관리자 계정이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="관리자 그룹에 불필요한 관리자 계정이 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi
check_esxi() {
    local result=$(ssh root@esxi 'vim-cmd vimsvc/auth/permissions')
    local admin_accounts=$(echo "$result" | grep -E "admin|root|administrator" | wc -l)
    if [ $admin_accounts -le 1 ]; then
        diagnosisResult="관리자 그룹에 불필요한 관리자 계정이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="관리자 그룹에 불필요한 관리자 계정이 있습니다."
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
