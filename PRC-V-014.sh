#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_mob_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "evaluationItemID,category,controlField,controlClassification1,controlClassification2,evaluationItem,riskLevel,detailedDescription,objectOfEvaluation_vCenter,objectOfEvaluation_ESXi,judgmentMethod_vCenter,judgmentCriteria_vCenter,judgmentMethod_ESXi,judgmentCriteria_ESXi,status,diagnosisResult" > $OUTPUT_CSV
fi

# Initial Values
evaluationItemID="PRC-V-014"
category="기술적 보안"
controlField="OS 가상화 시스템"
controlClassification1="2. 시스템 서비스 관리"
controlClassification2="1. 서비스 관리"
evaluationItem="MOB(Managed Object Browser) 서비스 비활성화"
riskLevel="3"
detailedDescription="MOB(Managed Object Browser) 서비스가 활성화 되어 있을 경우, 해당 인터페이스를 통해 시스템 정보 수집, 가상 머신 제어, 시스템 설정 변경 등의 위협이 발생 될 수 있으므로, MOB 서비스 비활성화 여부를 점검"
objectOfEvaluation_vCenter="ㅇ"
objectOfEvaluation_ESXi="ㅇ"
judgmentMethod_vCenter="1. vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# (vCenter6.5) '호스트 및 클러스터' > <vCenter 서버> > '구성' > '설정' > '고급 설정' >  'config.vpxd.enableDebugBrowse' 확인
# (vCenter8) '호스트 및 클러스터' > <vCenter 서버> > '구성' > '설정' > '고급 설정' >  'config.vpxd.enableDebugBrowse' 확인"
judgmentCriteria_vCenter="* 양호 : MOB(Managed Object Browser)가 비활성화 되어 있는 경우
* 취약 : MOB(Managed Object Browser)가 활성화 되어 있는 경우

※ default : true"
judgmentMethod_ESXi="1. SSH를 통해 ESXi 접속 후, 다음 명령어 실행
$ vim-cmd hostsvc/advopt/view Config.HostAgent.plugins.solo.enableMob
2. vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
# 관리 > 시스템 > 고급 설정 > Config.HostAgent.plugins.solo.enableMob 설정 값이 활성화(True)되어 있는지 확인"
judgmentCriteria_ESXi="* 양호 : Config.HostAgent.plugins.solo.enableMob 값이 false로 설정되어 있는 경우
* 취약 : Config.HostAgent.plugins.solo.enableMob 값이 true로 설정되어 있는 경우

※ default : false"

# Function to check vCenter MOB configuration
check_vcenter() {
    local mob_status=$(ssh root@vcenter 'vim-cmd vpxd.advOpt.view | grep "config.vpxd.enableDebugBrowse"')
    if [[ $mob_status == *"false"* ]]; then
        diagnosisResult="vCenter MOB(Managed Object Browser)가 비활성화 되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="vCenter MOB(Managed Object Browser)가 활성화 되어 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$evaluationItemID,$category,$controlField,$controlClassification1,$controlClassification2,$evaluationItem,$riskLevel,$detailedDescription,$objectOfEvaluation_vCenter,$objectOfEvaluation_ESXi,$judgmentMethod_vCenter,$judgmentCriteria_vCenter,$judgmentMethod_ESXi,$judgmentCriteria_ESXi,$status,$diagnosisResult" >> $OUTPUT_CSV
}

# Function to check ESXi MOB configuration
check_esxi() {
    local mob_status=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view Config.HostAgent.plugins.solo.enableMob')
    if [[ $mob_status == *"false"* ]]; then
        diagnosisResult="ESXi MOB(Managed Object Browser)가 비활성화 되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi MOB(Managed Object Browser)가 활성화 되어 있습니다."
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
