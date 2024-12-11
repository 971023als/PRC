	PRC-C-011	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	3. 로그 관리	원격 로그 서버 이용	3	원격 로그 서버를 이용하여 로그 관리를 하지 않을 경우, 시스템 가용성 저하, 침해에 따른 로그 유실 등의 위협이 발생될 수 있으므로 원격 로그 서버를 이용한 로그 저장 여부를 점검			ㅇ					"**Log Driver는 로그를 수집하고 저장하는 방식을 결정하는 옵션으로 관련 설정 존재 여부를 확인하며, 기본 log-driver는 json-file로 설정**

* (방법1) PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'log-driver' 인자값 확인
> $  ps -ef | grep 'dockerd' | grep -e ""log-driver"" | grep -v grep
>> --log-driver=json-file

* (방법2) 아래 명령어 실행 후, 'Storage Driver' 값 확인
> $ docker info --format '{{ .LoggingDriver }}' 
>> json-file

* (참고) Log Driver 종류
    - json-file: 로그를 JSON 형식의 파일로 저장
    - journald: 로그를 시스템의 journald 서비스로 전송
    - syslog: 로그를 시스템의 syslog 서비스로 전송
    - fluentd: 로그를 Fluentd 서비스로 전송
    - splunk: 로그를 Splunk 서비스로 전송
    - awslogs: 로그를 Amazon CloudWatch Logs 서비스로 전송"	"* 양호: 원격 로그 저장을 위한 Log Driver 설정이 적절하게 구성되어 있을 경우
* 취약: 
> - Log Driver가 json-file로 되어있고, 원격으로 로그를 전송하지 않는 경우
> - Log Driver가 journald, syslog 등으로 되어 있으나, 관련 서비스에 원격 로그 저장을 위한 설정이 되어 있지 않은 경우
> - log-opt 옵션을 사용하여 로그를 전송할 경우, 적절하지 않은 주소로 log-opt가 설정되어 있을 경우 등"													
