#!/bin/bash

OUTPUT_CSV="vmware_snmp_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-013"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="2. 시스템 서비스 관리"
controlClassification2="1. 서비스 관리"
evaluationItem="SNMP Community 스트링 복잡성 미충족"
riskLevel="3"
detailedDescription="SNMP Community 스트링이 유추하기 쉬운 문자열로 구성되어 있는 경우 비인가자가 SNMP 서비스에 무단 접근 가능할 수 있으므로, SNMP community string의 복잡성(최소길이, 문자종류) 요구사항 충족 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="if [[ $(vim-cmd proxysvc/service_list | grep 'TSM') ]]; then
  echo \"SNMP service is running on vcenter\"
else
  echo \"SNMP service is not running on vcenter\"
fi

cat /etc/vmware/snmp.xml | grep community | awk -F '\"' '{print $4}'"
judgmentCriteria_vCenter="* 양호 - SNMP Community String 초기 값(Public, Private)이 아니고, 아래의 복잡도를 만족 할 경우
* 취약 - SNMP Community String 초기 값(Public, Private)이거나, 복잡도를 만족하지 않은 경우

※ (복잡도) 기본값(public, private) 미사용, 영문자, 숫자가 포함 10자리 이상 또는 영문자, 숫자, 특수문자 포함 8자리 이상
※ SNMP v3의 경우 별도 인증 기능을 사용하고, 해당 비밀번호가 복잡도를 만족할 경우 \"양호\"로 판단"
judgmentMethod_ESXi="1. SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ esxcli system snmp get"
judgmentCriteria_ESXi="* 양호 - SNMP 서비스를 사용하지 않거나, SNMP Community String 초기 값(Public, Private)이 아니고, 아래의 복잡도를 만족할 경우
* 취약 - SNMP Community String 초기 값(Public, Private)이거나, 복잡도를 만족하지 않은 경우

※ (복잡도) 기본값(public, private) 미사용, 영문자, 숫자가 포함 10자리 이상 또는 영문자, 숫자, 특수문자 포함 8자리 이상
※ SNMP v3의 경우 별도 인증 기능을 사용하고, 해당 비밀번호가 복잡도를 만족할 경우 \"양호\"로 판단"

# Function to check vCenter SNMP configuration
check_vcenter() {
    local snmp_running=$(ssh root@vcenter 'vim-cmd proxysvc/service_list | grep "TSM"')
    if [[ $snmp_running ]]; then
        local community_string=$(ssh root@vcenter 'cat /etc/vmware/snmp.xml | grep community | awk -F '"' '{print $4}')
        if [[ $community_string && ${#community_string} -ge 10 && $community_string != "public" && $community_string != "private" ]]; then
            diagnosisResult="vCenter SNMP Community String이 적절하게 설정되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult"
        else
            diagnosisResult="vCenter SNMP Community String이 초기 값이거나 복잡도를 만족하지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult"
        fi
    else
        diagnosisResult="vCenter SNMP 서비스를 확인할 수 없습니다."
        status="정보 없음"
        echo "INFO: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi SNMP configuration
check_esxi() {
    local snmp_status=$(ssh root@esxi 'esxcli system snmp get')
    if [[ $snmp_status == *"Enabled"* ]]; then
        local community_string=$(ssh root@esxi 'esxcli system snmp get | grep "Communities"')
        if [[ $community_string && ${#community_string} -ge 10 && $community_string != *"public"* && $community_string != *"private"* ]]; then
            diagnosisResult="ESXi SNMP Community String이 적절하게 설정되어 있습니다."
            status="양호"
            echo "OK: $diagnosisResult"
        else
            diagnosisResult="ESXi SNMP Community String이 초기 값이거나 복잡도를 만족하지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult"
        fi
    else
        diagnosisResult="ESXi SNMP 서비스를 사용하지 않습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Perform checks
check_vcenter
check_esxi

# Display results
cat $OUTPUT_CSV
