	PRC-C-047	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	6. 컨테이너 리소스	컨테이너의 메모리 사용 제한	2	컨테이너에 메모리 사용제한이 설정되지 않을 경우, 특정 컨테이너의 메모리 과다 사용으로 인해 호스트 서버의 리소스가 고갈될 수 있으므로 컨테이너에 대한 메모리 사용제한 설정 여부를 점검	ㅇ		ㅇ	"* 'resources.limits.memory' 설정 값 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|resources.limits.memory:'{.resources.limits.memory}'{end}""

(Memory = 0인 경우 컨테이너가 메모리를 무제한으로 사용)
"	"* 양호 - resources.limits.memory가 적절하게 설정되어 있는 경우
* 취약 - resources.limits.memory가 0(무제한)으로 설정되어 있는 경우

※ default : 0 (무제한)
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**컨테이너의 메모리 무제한 사용(Memory=0) 가능 여부를 확인**

* (방법) docker 명령어를 사용하여 'HostConfig.Memory' 설정 값 확인
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Memory={{ .HostConfig.Memory }}'
>> - container_id1: Memory=0
>> - container_id2: Memory=256m"	"* 양호 - HostConfig.Memory가 적절하게 설정되어 있는 경우
* 취약 - HostConfig.Memory가 0으로 설정되어 있는 경우"													
