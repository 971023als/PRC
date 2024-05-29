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

PRC-V-009	기술적 보안	OS 가상화 시스템	1. 인증 및 접근제어	4. 접근 통제	관리 용도 외 IP 접근 미제한	4	관리 목적 이외의 IP에 대한 시스템 접근을 허용하고 있을 경우, 비인가자의 접근으로 인한 침해 위협이 발생 될 수 있으므로 관리 목적의 IP에 대해서만 시스템을 접근할 수 있도록 제한하고 있는지를 점검	ㅇ	ㅇ	"* 아래 방법을 통해 관리 용도 외 IP 접근 제한 여부를 확인

    1. 방화벽, iptables 정책 확인 후, 관리 목적 외 IP에서 접근 가능 여부를 확인"	"* 양호: 관리용도로 허용된 IP 외 접근 가능하지 않은 경우
* 취약: 관리용도로 허용된 IP 외 접근 가능할 경우"	"* 아래 방법을 통해 관리 용도 외 IP 접근 제한 여부를 확인

    1. 방화벽, iptables 정책 확인 후, 관리 목적 외 IP에서 접근 가능 여부를 확인"	"* 양호: 관리용도로 허용된 IP 외 접근 가능하지 않은 경우
* 취약: 관리용도로 허용된 IP 외 접근 가능할 경우"
