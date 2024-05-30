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

PRC-V-017	기술적 보안	OS 가상화 시스템	2. 시스템 서비스 관리	1. 서비스 관리	관리 홈페이지 세션 타임아웃 설정	3	비인가자에 의한 무단 사용을 방지하기 위해, 관리 홈페이지(웹 기반 관리 인터페이스)의 세션 타임아웃(로그인 후 일정시간 사용하지 않을 경우 세션 종료) 설정 적정성을 점검	ㅇ	ㅇ	"* 아래 방법을 통해 원격 접속 타임아웃을 설정

    1. (방법) vSphere Client 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       # (vCenter6.5) ""관리"" > ""Single Sign On"" > ""구성"" > ""Policies"" > ""잠금정책(Lockout Policy)"" > 접속제한 관련 설정(실패한 최대 로그인 시도 횟수, 실패 시간 간격, 잠금 해제 시간)을 확인
       # (vCenter8) ""관리"" > ""Single Sign On"" > ""구성"" > ""로컬 계정"" > ""잠금정책(Lockout Policy)"" > 접속제한 관련 설정(실패한 최대 로그인 시도 횟수, 실패 시간 간격, 잠금 해제 시간)을 확인"	"* 양호 - 세션 타임아웃 값(vpxd.httpClientIdleTimeout)이 900초 이하(15분)로 설정 되어 있을 경우
* 취약 - 세션 타임아웃 값(vpxd.httpClientIdleTimeout)이 0이거나, 900초 이하(15분)로 설정 되어 있지 않은 경우 (아래 내용 중 해당사항이 있는 경우)
  1) 내부 규정에 세션 종료 시간이 명시되어 있을 경우
     - 세션 타임아웃이 내부 규정에 명시된 세션 종료 시간보다 초과 설정 시 ""취약""으로 판단
  2) 내부 규정에 세션 종료시간이 명시되어 있지 않은 경우
     - 세션 타임아웃이 15분 초과 설정 시 ""취약""으로 판단

※ 모니터링 계정에 대해서는 세션 타임아웃에 대한 예외 허용"	"1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행 : Remote Host 확인
    $ vim-cmd hostsvc/advopt/view UserVars.HostClientSessionTimeout
2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
    # (5.5) ""관리"" > ""설정"" -> ""시스템"" -> ""고급 시스템 설정"" > UserVars.HostClientSessionTimeout 설정 확인
    # (6.5/6.7/7.0) ""관리"" > ""시스템"" -> ""고급 시스템 설정"" > UserVars.HostClientSessionTimeout 설정 확인


"	"* 양호 : 세션 타임아웃 값(HostClientSessionTimeout)이 900 이하일 경우
* 취약 : 세션 타임아웃 값(HostClientSessionTimeout)이 0이거나, 900초 이하(15분)로 설정 되어 있지 않은 경우 (아래 내용 중 해당사항이 있는 경우)
  1) 내부 규정에 세션 종료 시간이 명시되어 있을 경우
     - 세션 타임아웃이 내부 규정에 명시된 세션 종료 시간보다 초과 설정 시 ""취약""으로 판단
  2) 내부 규정에 세션 종료시간이 명시되어 있지 않은 경우
     - 세션 타임아웃이 15분 초과 설정 시 ""취약""으로 판단

※ Default : 900(15분)
※ 모니터링 계정에 대해서는 세션 타임아웃에 대한 예외 허용"

