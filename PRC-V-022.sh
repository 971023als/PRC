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

PRC-V-022	기술적 보안	OS 가상화 시스템	2. 시스템 서비스 관리	3. 로그 관리	원격 로그 서버 이용	3	원격 로그 서버를 이용하여 로그 관리를 하지 않을 경우, 시스템 가용성 저하, 침해에 따른 로그 유실 등의 위협이 발생될 수 있으므로 원격 로그 서버를 이용한 로그 저장 여부를 점검	ㅇ	ㅇ	"* 아래 방법을 통해 Syslog 설정 여부를 확인

    1. (방법) vCenter Server 관리 페이지(https://<주소>:5480/) 접속 후, 다음 메뉴에 접근하여 확인(vCenter 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # ""Syslog"" > Syslog 설정 여부를 확인"	"* 양호 : 원격 로그 서버 또는 스토리지가 연동 설정되어 있을 경우 양호
* 취약 : 원격 로그 서버 또는 스토리지가 연동 설정되어 있지 않은 경우 미흡"	"* 아래 방법을 통해 원격 로그 서버 사용 활성화 여부 확인

    1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행 : Remote Host 확인
       $ esxcli system syslog config get
    2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # (5.5) ""관리"" > ""설정"" -> ""시스템"" -> ""고급 시스템 설정"" > Syslog.global.logHost 설정 확인
       # (6.5/6.7/7.0) ""관리"" > ""시스템"" -> ""고급 시스템 설정"" > Syslog.global.logHost 설정 확인


"	"* 양호 : Syslog.global.logHost가 syslog 수집 서버로 설정되어 있을 경우
* 취약 : Syslog.global.logHost가 설정되어 있지 않을 경우"
