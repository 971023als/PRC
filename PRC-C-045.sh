	PRC-C-045	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	5. 컨테이너 네임스페이스	컨테이너의 호스트 UTS 네임스페이스 공유 최소화	3	"컨테이너에 UTS 네임스페이스 공유 옵션이 설정되어 있을 경우, 컨테이너가 호스트의 hostname을 변경하여 서비스 중단, 네트워크 통신 오류 등의 발생 시킬 수 있으므로 UTS 네임스페이스 공유 옵션 설정 여부를 점검

※ (참고) UTS 네임스페이스는 호스트 이름과 NIS 도메인 이름이라는 두 시스템 식별자 사이의 격리를 제공하며, 해당 네임스페이스에서 실행 중인 프로세스에 표시되는 호스트 이름과 도메인을 설정하는데 사용
    따라서, 컨테이너 내에서 실행되는 프로세스는 일반적으로 호스트 이름이나 도메인 이름을 알 필요가 없으므로, UTS 네임스페이스와의 공유는 불필요"	ㅇ		ㅇ	"*아래 명령어 실행 후, 'hostUTS' 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|securityContext.hostUTS:'{.securityContext.hostUTS}'{end}"""	"* 양호 - 'hostUTS'가 'false'로 설정되어 있지 않을 경우
* 취약 - 'hostUTS'가 'true'로 설정되어 있을 경우

※ default : false
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'HostConfig.UTSMode' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UTSMode={{ .HostConfig.UTSMode }}' 
>> - container_id1: UTSMode=host      # 컨테이너가 호스트의 UTS 네임스페이스를 공유
>> - container_id2: UTSMode=default  # 컨테이너가 자체적인 UTS 네임스페이스를 사용
>> - container_id3: UTSMode=container:container_id4 # 컨테이너가 다른 컨테이너의 UTS 네임스페이스를 공유"	"* 양호: 'HostConfig.UTSMode'에 값이 없거나, 'host'로 설정되어 있지 않을 경우
* 취약: 'HostConfig.UTSMode'가 'host'로 설정되어 있을 경우

"													
