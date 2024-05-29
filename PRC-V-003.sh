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


PRC-V-003	기술적 보안	OS 가상화 시스템	1. 인증 및 접근제어	1. 계정 관리	불필요하거나 관리되지 않는 계정 존재	4	시스템 설치 시 기본으로 생성되는 계정, 업무상 사용되지 않는 계정 등 불필요한 계정이나 장기간 비밀번호가 변경되지 않은 계정이 존재할 경우 비인가자의 계정 탈취 위협이 증가하므로 불필요하거나 관리되지 않는 계정 존재 여부를 점검	ㅇ	ㅇ	"* 아래 방법을 통해 계정 목록 및 적용 권한 확인

    1. (방법1) SSH를 통해 vCenter 접속 후, 다음 명령어 실행 (localos 계정 확인 방법)
       Command > com.vmware.appliance.version1.localaccounts.user.list
    2. (방법2) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # ""메뉴"" > ""관리"" > ""사용자 및 그룹"" > ""도메인"" 선택 > 계정정보 확인"	"* 양호 - 분기별 1회 이상 로그인 한 기록이 있고, 비밀번호를 변경하고 있는 경우
* 취약 - 분기별 1회 이상 로그인 한 기록이 없거나, 비밀번호를 변경하지 않은 경우

※ 업무상 사용 여부 확인 필요"	"* 아래 방법을 통해 계정 목록 및 적용 권한 확인

    1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
       $ vim-cmd vimsvc/auth/permissions
       $ cat /var/log/auth.log 명령어를 통해 접속일자 확인
    2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # ""관리"" > ""사용 권한"" > ""역할"" > 관리자 현황 확인"	"* 양호 - 분기별 1회 이상 로그인 한 기록이 있고, 비밀번호를 변경하고 있는 경우
* 취약 - 분기별 1회 이상 로그인 한 기록이 없거나, 비밀번호를 변경하지 않은 경우

※ 업무상 사용 여부 확인 필요"







































