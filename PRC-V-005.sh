#!/bin/bash

OUTPUT_CSV="vmware_password_policy_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-005"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="2. 비밀번호 정책 설정"
evaluationItem="비밀번호 변경 주기 불충족"
riskLevel="4"
detailedDescription="장기간 변경되지 않은 비밀번호 사용을 허가할 경우, 이전 획득한 비밀번호의 재사용, 무작위 대입을 통한 비밀번호 추측 등의 위협이 발생될 수 있으므로, 적절한 비밀번호 변경 주기 설정 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="* 아래 방법을 통해 비밀번호 변경주기 설정을 확인

1. (방법) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# (vCenter6.5) \"관리\" > \"Single Sign On\" > \"구성\" > \"Policies\" > \"암호정책\" > 비밀번호 변경주기(최대 수명) 확인
# (vCenter8) \"관리\" > \"Single Sign On\" > \"구성\" > \"로컬 계정\" > \"암호정책\" > 비밀번호 변경주기(최대 수명) 확인"
judgmentCriteria_vCenter="* 양호 - 비밀번호 변경 주기 설정(90일 이하)되어 있을 경우
* 취약 - 비밀번호 변경 주기 설정(90일 이하)되어 있지 않은 경우"
judgmentMethod_ESXi="1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ vim-cmd hostsvc/advopt/view Security.PasswordMaxDays
2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# (6.7/7.0) \"관리\" > \"시스템\" -> \"고급 시스템 설정\" > Security.PasswordMaxDays 설정 확인

※ 시스템이 관련 기능을 지원하지 않을 경우, 내부 정책 확인"
judgmentCriteria_ESXi="* 양호 - 비밀번호 변경 주기 설정(90일 이하)되어 있을 경우
* 취약 - 비밀번호 변경 주기 설정(90일 이하)되어 있지 않은 경우"

# Function to check vCenter password policy
check_vcenter() {
    local result=$(ssh root@vcenter 'localcli hardware ipmi bmc get | grep "PasswordMaxDays"')
    if [[ $result -le 90 ]]; then
        diagnosisResult="vCenter 비밀번호 변경 주기가 90일 이하로 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="vCenter 비밀번호 변경 주기가 설정되지 않았거나 90일을 초과합니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi password policy
check_esxi() {
    local result=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view Security.PasswordMaxDays')
    if [[ $result -le 90 ]]; then
        diagnosisResult="ESXi 비밀번호 변경 주기가 90일 이하로 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi 비밀번호 변경 주기가 설정되지 않았거나 90일을 초과합니다."
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
