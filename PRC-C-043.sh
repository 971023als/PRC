	PRC-C-043	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	5. 컨테이너 네임스페이스	컨테이너의 호스트 IPC 네임스페이스 공유 최소화	3	"IPC 네임스페이스는 호스트와 컨테이너 간에 IPC를 분리하는 역할을 수행하나, IPC 네임스페이스를 공유할 경우 컨테이너 내 프로세스가 호스트 시스템의 모든 IPC에 접근 및 조작할 수 있으므로, IPC 네임스페이스 공유 여부를 점검

* IPC(Inter Process Communication) : 프로세스 간 통신을 가능하게 하는 기술"	ㅇ		ㅇ	"*아래 명령어 실행 후, 'hostIPC' 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|spec.hostIPC:'{.spec.hostIPC}'{end}"""	"* 양호 - 'hostIPC'가 false로 설정되어 있을 경우
* 취약 - 'hostIPC'가 true로 설정되어 있을 경우

※ default : false
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'HostConfig.IpcMode' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: IpcMode={{ .HostConfig.IpcMode }}'
>> - container_id1: IpcMode=  # 버전에 따라, private 또는 shareable
>> - container_id2: IpcMode=None # /dev/shm이 마운트되지 않은 자체 개인 IPC 네임스페이스 사용
>> - container_id3: IpcMode=private # 자체 프라이빗 네임스페이스 사용
>> - container_id4: IpcMode=shareable  # 컨테이너가 다른 컨테이너의 IPC 네임스페이스를 공유
>> - container_id5: IpcMode=container:container_id4 # 타 컨테이너의 IPC 네임스페이스에 가입
>> - container_id6: IpcMode=host # 컨테이너가 호스트의 IPC 네임스페이스를 공유"	"* 양호: 'HostConfig.IpcMode'가 'host'로 설정되어 있지 않을 경우
* 취약: 'HostConfig.IpcMode'가 'host'로 설정되어 있을 경우

※ Default : private(각 컨테이너는 독립적인 IPC 네임스페이스를 가지며, 다른 컨테이너 간의 메모리 공간이나, 다른 IPC 자원을 격리)"													
