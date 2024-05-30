#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_security_assessment.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-003"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="1. 계정 관리"
evaluationItem="불필요하거나 관리되지 않는 계정 존재"
riskLevel="4"
detailedDescription="시스템 설치 시 기본으로 생성되는 계정, 업무상 사용되지 않는 계정 등 불필요한 계정이나 장기간 비밀번호가 변경되지 않은 계정이 존재할 경우 비인가자의 계정 탈취 위협이 증가하므로 불필요하거나 관리되지 않는 계정 존재 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="* 아래 방법을 통해 계정 목록 및 적용 권한 확인

1. (방법1) SSH를 통해 vCenter 접속 후, 다음 명령어 실행 (localos 계정 확인 방법)
Command > com.vmware.appliance.version1.localaccounts.user.list
2. (방법2) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"메뉴\" > \"관리\" > \"사용자 및 그룹\" > \"도메인\" 선택 > 계정정보 확인"
judgmentCriteria_vCenter="* 양호 - 분기별 1회 이상 로그인 한 기록이 있고, 비밀번호를 변경하고 있는 경우
* 취약 - 분기별 1회 이상 로그인 한 기록이 없거나, 비밀번호를 변경하지 않은 경우

※ 업무상 사용 여부 확인 필요"
judgmentMethod_ESXi="1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ vim-cmd vimsvc/auth/permissions
$ cat /var/log/auth.log 명령어를 통해 접속일자 확인
2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"관리\" > \"사용 권한\" > \"역할\" > 관리자 현황 확인"
judgmentCriteria_ESXi="* 양호 - 분기별 1회 이상 로그인 한 기록이 있고, 비밀번호를 변경하고 있는 경우
* 취약 - 분기별 1회 이상 로그인 한 기록이 없거나, 비밀번호를 변경하지 않은 경우

※ 업무상 사용 여부 확인 필요"

# Function to check vCenter
check_vcenter() {
    local result=$(ssh root@vcenter 'com.vmware.appliance.version1.localaccounts.user.list')
    local inactive_accounts=$(echo "$result" | grep -E "lastLogin|passwordLastSet" | awk -F':' '{if ($2 < (date +%s - 7776000)) print $1}' | wc -l)
    if [ $inactive_accounts -eq 0 ]; then
        diagnosisResult="불필요하거나 관리되지 않는 계정이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="불필요하거나 관리되지 않는 계정이 존재합니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi
check_esxi() {
    local result=$(ssh root@esxi 'vim-cmd vimsvc/auth/permissions')
    local inactive_accounts=$(echo "$result" | grep -E "lastLogin|passwordLastSet" | awk -F':' '{if ($2 < (date +%s - 7776000)) print $1}' | wc -l)
    if [ $inactive_accounts -eq 0 ]; then
        diagnosisResult="불필요하거나 관리되지 않는 계정이 없습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="불필요하거나 관리되지 않는 계정이 존재합니다."
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
