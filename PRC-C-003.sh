	PRC-C-003	기술적 보안	"컨테이너
가상화
시스템"	1. 인증 및 접근제어	1. 서비스 어카운트 관리	기본 서비스 계정(default) 사용	4	기본 서비스 계정은 네임스페이스 내의 모든 리소스에 대한 접근 권한을 가질 수 있으므로, 불필요한 기본 서비스 계정 사용 유무를 점검	ㅇ			"* 서비스 계정 목록 확인 후, 기본 계정 사용 여부를 확인

  $ kubectl get pods -A -o=jsonpath='{range .items[*]}{.metadata.name}:{.metadata.namespace}:{.spec.serviceAccountName}{""
""}{end}'"	"* 양호 - POD가 기본 서비스 계정(default)를 사용하고 있지 않을 경우
* 취약 - POD가 기본 서비스 계정(default)를 사용하고 있는 경우

※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"																	
