	PRC-C-044	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	5. 컨테이너 네임스페이스	컨테이너의 호스트 네트워크 네임스페이스 공유 최소화	3	"컨테이너에 네트워크 네임스페이스 공유 옵션이 설정되어 있을 경우, 컨테이너 내 프로세스가 호스트 시스템의 네트워크 인터페이스에 접근 및 조작 권한을 얻게 됨에 따라 네트워크 스니핑, 불필요한 서비스 구동 등의 보안 위협이 발생 될 수 있으므로, 네트워크 네임스페이스 공유 옵션 설정 여부를 점검

※ (참고) 네트워크 네임스페이스는 각 컨테이너에 독립적인 네트워크 스택, IP 주소, 라우트 테이블 및 포트를 제공하여 다른 컨테이너나 호스트로부터의 네트워크를 격리"	ㅇ		ㅇ	"*아래 명령어 실행 후, 'hostNetwork' 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|spec.hostNetwork:'{.spec.hostNetwork}'{end}"""	"* 양호 - 'hostNetwork'가 false로 설정되어 있을 경우
* 취약 - 'hostNetwork'가 true로 설정되어 있을 경우

※ default : false
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'NetworkMode'가 bridge, host로 설정 여부를 확인**

* (방법) docker 명령어를 사용하여 'HostConfig.NetworkMode' 설정 값 확인
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: NetworkMode={{ .HostConfig.NetworkMode }}'
>> - container_id1: NetworkMode=none # 컨테이너는 네트워크를 사용하지 않으며, 컨테이너는 완전히 격리되어 있는 상태로 네트워크 연결이 필요하지 않을 때 사용
>> - container_id2: NetworkMode=bridge # 컨테이너 간 통신을 위한 기본적인 네트워크 모드
>> - container_id3: NetworkMode=host # 컨테이너는 호스트 머신의 네트워크 네임스페이스를 공유하며, 컨테이너는 호스트 머신과 동일한 네트워크 인터페이스를 사용하며, 호스트의 IP 주소 및 포트를 직접 사용할 수 있음"	"* 양호: 
> - NetworkMode가 host, bridge 외의 모드로 구성되어 있을 경우
> - NetworkMode가 bridge로 구성되어 있으나, icc 옵션이 설정되어 있는 경우
* 취약:
> - NetworkMode가 host 모드로 구성되어 있을 경우
> - NetworkMode가 bridge로 구성되어 있으며, icc 옵션이 설정되지 않은 경우

※ Default : bridge"													
