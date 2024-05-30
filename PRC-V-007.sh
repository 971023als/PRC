#!/bin/bash

OUTPUT_CSV="vmware_login_policy_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-007"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="3. 인증 정책 설정"
evaluationItem="로그인 실패 횟수에 따른 접속 제한 설정 미흡"
riskLevel="3"
detailedDescription="일정 횟수 이상의 잘못된 비밀번호 입력을 허용할 경우 무작위 대입 공격과 같은 위협이 발생될 수 있으므로 비밀번호 오류에 따른 접속 제한(계정 잠금, 차단 등) 설정 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="* 아래 방법을 통해 로그인 실패 횟수에 따른 접속제한 관련 설정을 확인

1. (방법) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# (vCenter6.5) \"관리\" > \"Single Sign On\" > \"구성\" > \"Policies\" > \"잠금정책(Lockout Policy)\" > 접속제한 관련 설정(실패한 최대 로그인 시도 횟수, 실패 시간 간격, 잠금 해제 시간)을 확인
# (vCenter8) \"관리\" > \"Single Sign On\" > \"구성\" > \"로컬 계정\" > \"잠금정책(Lockout Policy)\" > 접속제한 관련 설정(실패한 최대 로그인 시도 횟수, 실패 시간 간격, 잠금 해제 시간)을 확인"
judgmentCriteria_vCenter="* 양호 - 실패한 최대 로그인 시도 횟수 5회, 실패 시간 간격 0, 잠금 해제 시간 0으로 설정되어 있을 경우
* 취약 - 실패한 최대 로그인 시도 횟수 5회, 실패 시간 간격 0, 잠금 해제 시간 0으로 설정되어 있지 않은 경우"
judgmentMethod_ESXi="1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ vim-cmd hostsvc/advopt/view Security.AccountLockFailures
$ vim-cmd hostsvc/advopt/view Security.AccountUnlockTime
2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# (6.7/7.0) \"관리\" > \"시스템\" -> \"고급 시스템 설정\" > Security.AccountLockFailures, Security.AccountUnlockTime 설정 확인

※ 시스템이 관련 기능을 지원하지 않을 경우, 내부 정책 확인"
judgmentCriteria_ESXi="* 양호 - 로그인 시도 실패 횟수 5회 이하, 계정 잠금 15분 이상으로 적용되어 있을 경우
* 취약 - 로그인 시도 실패 횟수 5회 초과, 계정 잠금 15분 미만으로 적용되어 있을 경우"

# Function to check vCenter login policy
check_vcenter() {
    local result_failures=$(ssh root@vcenter 'localcli hardware ipmi bmc get | grep "LockoutAttempts"')
    local result_unlock_time=$(ssh root@vcenter 'localcli hardware ipmi bmc get | grep "UnlockTime"')
    if [[ $result_failures -le 5 ]] && [[ $result_unlock_time -ge 15 ]]; then
        diagnosisResult="vCenter 로그인 실패 횟수 및 계정 잠금 시간이 적절하게 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="vCenter 로그인 실패 횟수 및 계정 잠금 시간이 적절하게 설정되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi login policy
check_esxi() {
    local result_failures=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view Security.AccountLockFailures')
    local result_unlock_time=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view Security.AccountUnlockTime')
    if [[ $result_failures -le 5 ]] && [[ $result_unlock_time -ge 15 ]]; then
        diagnosisResult="ESXi 로그인 실패 횟수 및 계정 잠금 시간이 적절하게 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi 로그인 실패 횟수 및 계정 잠금 시간이 적절하게 설정되지 않았습니다."
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
