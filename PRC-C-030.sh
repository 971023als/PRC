	PRC-C-030	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	2. 컨테이너 권한 관리	컨테이너 및 POD에 seccomp 활성화 및 적용	5	"seccomp(Secure Computing Mode)을 사용할 경우, 컨테이너 내의 프로세스가 사용할 수 있는 악의적인 시스템 호출을 제한할 수 있으므로 seccomp 활성화 및 적용 여부를 점검

* 기본 seccomp 프로필은 컨테이너 격리 경계를 우회하고 노드 또는 다른 컨테이너에 대한 액세스 권한을 허용하는 데 사용할 수 있는 syscall(reboot, kexec_load, open_by_handle_at 등)을 차단  (컨테이너 내부에서 특정 시스템 호출을 사용하는 잠재적인 공격을 방지하는 데 특화)
"	ㅇ		ㅇ	"* 개별 POD에서 seccomp 설정의 적용 여부를 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}.name}|securityContext.seccompProfile.type:'{.securityContext.seccompProfile.type}'|securityContext.seccompProfile.localhostProfile:'{.securityContext.seccompProfile.localhostProfile}'{''}{end}"""	"* 양호 - seccomp 프로파일이 적용되어 있는 경우
* 취약 - seccomp 프로파일을 적용하지 않은 경우

※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"* (방법1) 아래 명령어 실행 후, 'SecurityOptions' 값 확인
> $ docker info --format '{{ .SecurityOptions }}'
>> [seccomp apparmor]  # Docker가 'seccomp', 'apparmor' 를 사용 중

* (방법2) 아래 명령어 실행 후, 'HostConfig.SecurityOpt' 설정 확인
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'   
>> container1: SecurityOpt=[seccomp:unconfined] # container1 컨테이너가 seccomp 보안 옵션을 사용하고 있으며, 모든 시스템 호출을 허용하는 'undefined' 프로파일을 적용중
>> container2: SecurityOpt=[seccomp:profile:/var/lib/kubelet/seccomp/profiles/custom-profile.json] # seccomp 보안 옵션을 사용하고 있으며, 각 컨테이너의 seccomp 프로파일은 /var/lib/kubelet/seccomp/profiles/custom-profile.json으로 설정
>> container3: SecurityOpt=[] # container3 컨테이너는 seccomp 보안 옵션 미사용
>> container4: SecurityOpt=[seccomp:profile:/var/lib/kubelet/seccomp/profiles/docker-default] # container3 컨테이너는 seccomp 보안 옵션을 사용하고 있으며, docker 기본 프로파일을 사용 중"	"* 양호: seccomp 프로파일이 적용되어 있는 경우
* 취약: seccomp 프로파일이 비활성화 되어 있는 경우(또는 seccomp 프로파일이 unconfined로 설정되어 있는 경우)

※ 기본값 : 활성화"													
