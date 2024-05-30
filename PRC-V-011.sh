#!/bin/bash

OUTPUT_CSV="vmware_system_notice_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-011"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="2. 시스템 서비스 관리"
controlClassification2="1. 서비스 관리"
evaluationItem="시스템 사용 주의사항 미출력"
riskLevel="1"
detailedDescription="원격 로그인 시 시스템 사용 주의사항을 안내하지 않을 경우 사용자가 시스템에 접근 시 보안 정책을 인식하지 못해 인위적인 공격 또는 데이터 유출 등의 보안 위협이 생길 수 있으므로, 원격 로그인 시 시스템 사용 주의사항 등의 경고 문구를 표시하는 설정의 존재 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="1. vSphere Client 접속 후, 다음 메뉴에 접근하여 확인
# (vCenter6.5) '관리' > 'Single Sign On' > '구성' > '로그인 배너' > 로그인 배너 설정 여부를 확인
# (vCenter8) '관리' > 'Single Sign On' > '구성' > '로그인 메시지' > 로그인 배너 설정 여부를 확인"
judgmentCriteria_vCenter="* 양호 - 시스템 사용 주의사항을 출력하는 경우
* 취약 - 시스템 사용 주의사항 미출력 시 또는 표시 문구 내에 시스템 버전 정보가 노출되는 경우"
judgmentMethod_ESXi="[ESXi 6.5 관리콘솔 확인방법]
1. 관리 > 시스템 > 고급설정
2. 키 : Annotations.WelcomeMessage 옵션 확인
- 다음의 파일들에 메시지 설정 존재 여부 확인
1. /etc/motd 에 시스템 사용 주의사항 설정
2. /etc/issue 파일에 로그인 경고메세지 설정
3. /etc/ssh/sshd_config Banner 값 설정"
judgmentCriteria_ESXi="* 양호 - 시스템 사용 주의사항(WelcomeMessage, issue, motd)을 출력하는 경우
* 취약 - 시스템 사용 주의사항(WelcomeMessage, issue, motd) 미출력 또는 표시 문구 내에 시스템 버전 정보가 노출되는 경우"

# Function to check vCenter system notice
check_vcenter() {
    local result=$(ssh root@vcenter 'localcli software vib list | grep "VMware-vSphere-Client"')
    if [[ $result ]]; then
        local banner=$(ssh root@vcenter 'localcli hardware ipmi bmc get | grep "Banner"')
        if [[ $banner ]]; then
            diagnosisResult="vCenter 시스템 사용 주의사항이 출력되고 있습니다."
            status="양호"
            echo "OK: $diagnosisResult"
        else
            diagnosisResult="vCenter 시스템 사용 주의사항이 출력되지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult"
        fi
    else
        diagnosisResult="vCenter를 확인할 수 없습니다."
        status="정보 없음"
        echo "INFO: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi system notice
check_esxi() {
    local motd=$(ssh root@esxi 'cat /etc/motd')
    local issue=$(ssh root@esxi 'cat /etc/issue')
    local ssh_banner=$(ssh root@esxi 'grep "Banner" /etc/ssh/sshd_config')

    if [[ $motd || $issue || $ssh_banner ]]; then
        diagnosisResult="ESXi 시스템 사용 주의사항이 출력되고 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi 시스템 사용 주의사항이 출력되지 않습니다."
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
