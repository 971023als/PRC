	PRC-C-042	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	5. 컨테이너 네임스페이스	컨테이너의 호스트 PID 네임스페이스 공유 최소화	3	PID 네임스페이스는 호스트와 컨테이너 간에 프로세스를 분리하는 역할을 수행하나, PID 네임스페이스를 공유할 경우 컨테이너 내 프로세스가 호스트 시스템의 모든 프로세스에 접근 및 조작할 수 있으므로, PID 네임스페이스 공유 여부를 점검	ㅇ		ㅇ	"*아래 명령어 실행 후, 'hostPID' 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|spec.hostPID:'{.spec.hostPID}'{end}"""	"* 양호 - 'hostPID'가 false로 설정되어 있을 경우 
* 취약 - 'hostPID'가 true로 설정되어 있을 경우

※ default : false
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'HostConfig.PidMode' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: PidMode={{ .HostConfig.PidMode }}'
>> - container_id1: PidMode=  # 컨테이너가 자체적인 PID 네임스페이스를 사용
>> - container_id2: PidMode=host      # 컨테이너가 호스트의 PID 네임스페이스를 공유
>> - container_id3: PidMode=container:container_id4 # 컨테이너가 다른 컨테이너의 PID 네임스페이스를 공유"	"* 양호: 'HostConfig.PidMode'가 'host'로 설정되어 있지 않을 경우
* 취약: 'HostConfig.PidMode'가 'host'로 설정되어 있을 경우

※ Default : default(각 컨테이너는 독립적인 PID 네임스페이스를 가지며, 다른 컨테이너나 호스트 시스템의 프로세스와는 분리)"													
