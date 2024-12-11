	PRC-C-028	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	2. 컨테이너 권한 관리	불필요한 커널 접근 권한 제거	4	"높은 수준의 커널 접근 권한(capabilities)을 제거 하지 않을 경우, 컨테이너는 호스트 시스템의 커널에 높은 접근 권한을 가질 수 있으므로, 업무상 필요하지 않은 capabilities를 제거(drop)하였는지를 점검

※ SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE"	ㅇ			"* 개별 POD에서 capabilities 설정의 적용 여부를 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|securityContext.capabilities.drop:'{.securityContext.capabilities.drop}'{''}{end}"""	"* 양호 - capability.drop에 SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE 등이 부여되어 있을 경우
* 취약 - capability.drop에 SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE 등이 부여되어 있지 않을 경우

※ capability.drop과 capability.add에 동시 적용되어 있을 경우, capability.drop이 적용
※ 서버보안 솔루션에서 해당 기능을 통제할 경우 양호
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"																	
