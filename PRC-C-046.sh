	PRC-C-046	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	6. 컨테이너 리소스	HostPort 사용 컨테이너의 허용 최소화	4	"HostPort를 사용하는 컨테이너는 호스트 시스템의 포트를 직접 사용할 수 있으므로, 불필요한 HostPort 사용 여부를 점검

※ 인터넷 또는 내부 네트워크를 통해 직접적인 접속이 불필요한 서비스(WAS, DB)의 경우 hostport 노출 최소화 필요"	ㅇ			"* 개별 POD에서 hostNetwork 설정의 적용 여부를 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|{range .ports[*]}{.name}:{.containerPort}:{.hostPort}:{.protocol};{end}{end}"""	"* 양호 - 불필요한 hostPort 가 존재 하지 않을 경우
* 취약 - 불필요한 hostPort 가 존재 하는 경우

※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"																	
