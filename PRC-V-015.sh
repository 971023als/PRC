#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="웹 보안"
code="SRV-044"
riskLevel="중"
diagnosisItem="파일 업로드 및 다운로드 크기 제한 검사"
service="Account Management"
diagnosisResult=""
status=""

BAR

CODE="SRV-044"
diagnosisItem="웹 서비스 파일 업로드 및 다운로드 용량 제한 미설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 웹 서비스에서 파일 업로드 및 다운로드 용량이 적절하게 제한된 경우
[취약]: 웹 서비스에서 파일 업로드 및 다운로드 용량이 제한되지 않은 경우
EOF

BAR

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
file_exists_count=0

for webconf_file in "${webconf_files[@]}"; do
    find_webconf_files=($(find / -name "$webconf_file" -type f 2>/dev/null))
    for file in "${find_webconf_files[@]}"; do
        ((file_exists_count++))
        limit_request_body_count=$(grep -vE '^#|^\s#' "$file" | grep -i 'LimitRequestBody' | wc -l)
        if [ $limit_request_body_count -eq 0 ]; then
            diagnosisResult="Apache 설정 파일에 파일 업로드 및 다운로드 용량을 제한하는 설정이 없습니다: $file"
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
done

if [ $file_exists_count -eq 0 ]; then
    diagnosisResult="Apache 설정 파일을 찾을 수 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="웹 서비스에서 파일 업로드 및 다운로드 용량이 적절하게 제한된 경우"
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV


위에 형식으로 맞게 코드 만들어줘 json 형태 말고 csv 형태로

VMWare vCenter,VMWare ESXi 

어떠한 환경인지 파악하고 그거 맞는 쉘 스크립트 코드를 형태로 만들어줘



평가항목ID	구분	통제분야	통제구분(대)	통제구분(중)	평가항목	위험도	상세설명	"평가대상
(VMWare vCenter)"	"평가대상
(VMWare ESXi)"	"판단방법
(vCenter)"	"판단기준
(vCenter)"	"판단방법
(ESXi)"	"판단기준
(ESXi)"

PRC-V-015	기술적 보안	OS 가상화 시스템	2. 시스템 서비스 관리	1. 서비스 관리	이미지 프로필 및 VIB 승인 레벨 설정 미흡	3	"신뢰할 수 없는 VIB(Vsphere Install Bundle) 설치를 허용할 경우 악의적인 기능을 수행하는 소프트웨어가 설치될 수 있으므로, 해당 벤더사 또는 신뢰할 수 있는 파트너 테스트를 거친 VIB만 설치하였는지 점검

* VIB(Vsphere Install Bundle) : ESXi에 설치 가능한 소프트웨어 패키지"	-	ㅇ			"* 아래 방법을 통해 VIB 정책 확인

    1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
       $ esxcli software acceptance get
    2. (방법) SSH를 통해 ESXi 접속 후, 다음 명령어 실행 후 설치된 소프트웨어 목록 확인
       $ esxcli software vib list 
    3. (방법3) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # 관리 > 보안 및 사용자 > 수락수준
    4. (방법4) vCenter 접속 후, 다음 메뉴에 접근 후 수락 수준 설정 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # 메뉴 > 호스트 및 클러스터 > 해당 ESXi(하이퍼바이저) 선택 > 구성 > 시스템 > 보안 프로파일 > 호스트 이미지 프로파일 수락 수준 > 편집 선택 후 설정 확인"	"* 양호 : VIB 승인 레벨이 Partner Supported 이상인 경우
* 취약 : VIB 승인 레벨이 Community Supported 인 경우

※ Default : PartnerSupported

[ VIB 승인 레벨 ]
• VMware 인증(VMware Certified) : VMware에서 만들고 테스트 한 VIB
• VMware 수락(VMware Accepted) : VMware에서 승인 한 VMware 파트너가 생성 한 VIB, VMware는 파트너에 의존하여 테스트를 수행하지만 VMware는 결과를 확인
• 파트너(Partner Supported) : 신뢰할 수있는 VMware 파트너가 만들고 테스트 한 VIB, 파트너가 모든 테스트를 수행
• 커뮤니티(Community Supported) : VMware 파트너 프로그램 외부의 개인 또는 파트너가 만든 VIB, 이러한 VIB는 VMware 또는 신뢰할 수있는 파트너 테스트를 거치지 않으며 VMware 또는 해당 파트너가 지원하지 않음"
