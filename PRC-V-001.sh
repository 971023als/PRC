#!/bin/bash

OUTPUT_CSV="vmware_security_assessment.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-001"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="1. 인증 및 접근제어"
controlClassification2="1. 계정 관리"
evaluationItem="사용자별 계정 분리 미흡"
riskLevel="3"
detailedDescription="사용자별 계정을 분리하지 않고 사용하는 경우(공용계정을 사용하는 경우) 사용자 행위 등의 감사추적에 어려움이 존재함에 따라 사용자 행위 등의 감사추적을 위한 공용계정 사용 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="* 아래 방법을 통해 계정 목록 및 적용 권한 확인

1. (방법1) SSH를 통해 vCenter 접속 후, 다음 명령어 실행 (localos 계정 확인 방법)
Command > com.vmware.appliance.version1.localaccounts.user.list
2. (방법2) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"메뉴\" > \"관리\" > \"사용자 및 그룹\" > \"도메인\" 선택 > 계정정보 확인"
judgmentCriteria_vCenter="* 양호 - 계정들이 사용자별로 적절하게 분리되어 사용되고 있는 경우 (계정을 공유해서 사용 하는 경우, 서드파티 솔루션 등을 통해 접속자별 감사로그 식별 가능시 양호로 판단)
* 취약 - 계정들이 사용자별로 적절하게 분리되지 않고 사용되고 있는 경우"
judgmentMethod_ESXi="1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ vim-cmd vimsvc/auth/permissions
$ cat /var/log/auth.log 명령어를 통해 사용 IP 확인
2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# \"관리\" > \"사용 권한\" > \"역할\" > 관리자 현황 확인"
judgmentCriteria_ESXi="* 양호 - 계정들이 사용자별로 적절하게 분리되어 사용되고 있고 있는 경우 (계정을 공유해서 사용 하는 경우, 서드파트솔루션등을 통해 접속자별 감사로그 식별 가능시 양호로 판단)
* 취약 - 계정들이 사용자별로 적절하게 분리되지 않고 사용되고 있는 경우, 계정 목록 내 root만 존재할 경우"

# Function to check vCenter
check_vcenter() {
    local result=$(ssh root@vcenter 'com.vmware.appliance.version1.localaccounts.user.list')
    local users=$(echo "$result" | grep "username" | wc -l)
    if [ $users -gt 1 ]; then
        echo "OK: vCenter 사용자 계정들이 적절하게 분리되어 있습니다."
        echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,양호,vCenter 사용자 계정들이 적절하게 분리되어 있습니다." >> $OUTPUT_CSV
    else
        echo "WARN: vCenter 사용자 계정들이 적절하게 분리되지 않았습니다."
        echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,취약,vCenter 사용자 계정들이 적절하게 분리되지 않았습니다." >> $OUTPUT_CSV
    fi
}

# Function to check ESXi
check_esxi() {
    local result=$(ssh root@esxi 'vim-cmd vimsvc/auth/permissions')
    local users=$(echo "$result" | grep "User" | wc -l)
    if [ $users -gt 1 ]; then
        echo "OK: ESXi 사용자 계정들이 적절하게 분리되어 있습니다."
        echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,양호,ESXi 사용자 계정들이 적절하게 분리되어 있습니다." >> $OUTPUT_CSV
    else
        echo "WARN: ESXi 사용자 계정들이 적절하게 분리되지 않았습니다."
        echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,취약,ESXi 사용자 계정들이 적절하게 분리되지 않았습니다." >> $OUTPUT_CSV
    fi
}

# Perform checks
check_vcenter
check_esxi

# Display results
cat $OUTPUT_CSV
