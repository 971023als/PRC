	PRC-C-026	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	2. 컨테이너 권한 관리	컨테이너의 privileged 플래그 실행	5	"privileged 플래그를 사용하여 컨테이너를 실행하는 경우, cgroup  컨트롤러 등에 의해 시행되는 모든 제한 사항이 제거되어, 컨테이너에서 호스트 시스템에 접근할 수 있는 보안 위협이 발생될 수 있으므로, privileged 플래그 제거 여부를 점검

※ privileged 플래그가 설정되어 있을 경우 컨테이너에서 호스트 시스템의 디바이스에 대한 접근(Access) 권한을 부여"	ㅇ		ㅇ	"* 클러스터의 각 네임스페이스에서 사용중인 정책 중, privileged 설정 상태를 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|securityContext.privileged:'{.securityContext.privileged}'{''}{end}"""	"* 양호 - 'privileged'가 false로 설정되어 있는 경우
* 취약 - 'privileged'가 true로 설정되어 있는 경우

※ default : false
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 컨테이너에 적용된 privileged 값 확인**

* (방법) docker 명령어를 사용하여 'HostConfig.Privileged' 설정 값 확인
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Privileged={{ .HostConfig.Privileged }}'
>> container_id1: Privileged=false
>> container_id2: Privileged=true"	"* 양호 - ""privileged"" 값이 true로 설정된 컨테이너가 존재하지 않을 경우
* 취약 - ""privileged"" 값이 true로 설정된 컨테이너가 존재할 경우

※ 기본값 : false"													
