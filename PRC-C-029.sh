	PRC-C-029	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	2. 컨테이너 권한 관리	컨테이너의 권한 통제 설정	4	"컨테이너는 suid, sgid 등을 통한 권한 상승을 시도를 사전에 방지하기 위해, 컨테이너의 권한 통제 설정 여부를 점검

※ (참고) 권한 통제 설정이 되어 있지 않을 경우, suid가 설정된 실행 파일(/bin/ping)을 이용하여 일반 사용자가 컨테이너 내부에서 외부로의 명령 전달(ICMP 트래픽을 호스트 시스템으로 전달)하거나, execve를 통해 새로운 프로세스를 실행할 경우 컨테이너 외부에서 내부로의 명령 전달 가능

※ 'allowPrivilegeEscalation', 'no-new-privileges' 설정이 비활성화 될 경우 컨테이너 내부의 프로세스는 suid나 sgid 실행 파일과 같은 메커니즘을 통해 권한을 상승 가능"	ㅇ		ㅇ	"* 개별 POD에서 allowPrivilegeEscalation 설정의 적용 여부를 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|securityContext.allowPrivilegeEscalation:'{.securityContext.allowPrivilegeEscalation}'{''}{end}"""	"* 양호 - 'allowPrivilegeEscalation' 값이 false로 구성되어 있을 경우
* 취약 - 'allowPrivilegeEscalation' 값이 없거나, true로 구성되어 있을 경우

※ 기본값 : true
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"ㅇ 'no-new-privileges' 옵션은 Docker 컨테이너가 처음 실행될 때의 권한 상태를 유지하도록 하여, 이후에는 권한을 더 얻을 수 없도록 하는 옵션으로 관련 설정 존재 여부를 확인

* (방법1) Docker 데몬 명령줄에 'no-new-privileges' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""no-new-privileges"" | grep -v grep
>> root     12345   1     0   Jul09   ?   00:00:00 dockerd --no-new-privileges

* (방법2) 아래 명령어 실행 후, 'no-new-privileges' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""no-new-privileges""
>> ""no-new-privileges"": true,

* (방법3) 아래 명령어 실행 후, 'Storage Driver' 값 확인
> $ docker info --format '{{ .SecurityOptions }}'
>> [no-new-privileges]"	"* 양호 - ""no-new-privileges"" 값이 true로 설정되어 있는 경우
* 취약 - ""no-new-privileges"" 값이 false로 설정되어 있을 경우

※ 기본값 : true"													
