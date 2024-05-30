#!/bin/bash

OUTPUT_CSV="vmware_ntp_sync_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-012"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="2. 시스템 서비스 관리"
controlClassification2="1. 서비스 관리"
evaluationItem="시간 동기화를 위한 NTP 설정"
riskLevel="2"
detailedDescription="시스템이 NTP를 통한 시간 동기화가 되지 않을 경우 침해, 장애 등의 위협 발생 시 로그 분석에 어려움이 발생될 수 있으므로 NTP 설정을 통한 시간 동기화 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="1. vCenter Server 관리 페이지(https://<주소>:5480/) 접속 후, 다음 메뉴에 접근하여 확인(vCenter 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# '시간' > '시간 동기화' > NTP 설정 여부를 확인"
judgmentCriteria_vCenter="* 양호 : NTP 설정 및 시각 동기화가 되어 있는 경우
* 취약 : NTP 설정 및 시각 동기화가 안되어 있는 경우"
judgmentMethod_ESXi="1. SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ esxcli system ntp get
$ esxcli system ntp config get
2. vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# 호스트 > 관리 > 시스템 > 시간 및 날짜 > 설정 편집 > 네트워크 시간 프로토콜 사용(NTP 클라이언트 사용) > NTP 서버 설정 확인"
judgmentCriteria_ESXi="* 양호 : NTP 설정 및 시각 동기화가 되어 있는 경우
* 취약 : NTP 설정 및 시각 동기화가 안되어 있는 경우"

# Function to check vCenter NTP configuration
check_vcenter() {
    local result=$(ssh root@vcenter 'localcli software vib list | grep "VMware-vSphere-Client"')
    if [[ $result ]]; then
        local ntp_status=$(ssh root@vcenter 'ntpq -p')
        if [[ $ntp_status ]]; then
            diagnosisResult="vCenter NTP 설정 및 시각 동기화가 되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult"
        else
            diagnosisResult="vCenter NTP 설정 및 시각 동기화가 되어 있지 않습니다."
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

# Function to check ESXi NTP configuration
check_esxi() {
    local ntp_status=$(ssh root@esxi 'esxcli system ntp get')
    local ntp_config=$(ssh root@esxi 'esxcli system ntp config get')

    if [[ $ntp_status == *"Enabled"* && $ntp_config ]]; then
        diagnosisResult="ESXi NTP 설정 및 시각 동기화가 되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi NTP 설정 및 시각 동기화가 되어 있지 않습니다."
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
