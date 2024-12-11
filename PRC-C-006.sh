	PRC-C-006	기술적 보안	"컨테이너
가상화
시스템"	1. 인증 및 접근제어	2. 인증 정책 설정	서비스 계정 토큰 수명 제한 설정	3	서비스 어카운트에 대한 토큰 수명을 제한하는 설정을 하지 않을 경우, 토큰 정보 유출에 따른 무단 접근 등 보안 위협이 발생될 수 있으므로 서비스 어카운트 토큰에 대한 수명 제한 설정 여부를 점검	ㅇ			"* BoundServiceAccountTokenVolume 활성화 여부 확인
  - (방법1) $ ps -ef | grep apiserver | grep -E BoundServiceAccountTokenVolume | grep -v grep
  - (방법2) $ grep -E ""BoundServiceAccountTokenVolume"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""

* 토큰 만료 기간 확인
 $ kubectl get serviceaccount --all-namespaces -o=jsonpath=""{range .items[*]}{'Namespace: '}{.metadata.namespace}|{.metadata.name}|{'Tokens Expiry: '}{range .secrets[*]}{.expirationTimestamp}{' '}{end}{'\n'}{end}"""	"* 양호 - 'BoundServiceAccountTokenVolume'가 true로 설정되어 있거나, 수동으로 서비스 계정에 대한 토큰 만료 기간(expirationTimestamp)을 설정한 경우
* 취약 - 'BoundServiceAccountTokenVolume'가 false로 설정되어 있고, 서비스 계정에 대한 토큰 만료 기간(expirationTimestamp)이 설정되지 않은 경우

※ kubernetes 1.21 이상 버전에서는 디폴트 활성화
※ kubernetes 1.21 미만 버전에서는 서비스 계정에 대한 토큰 만료를 수동으로 설정
※ BoundServiceAccountTokenVolume가 설정되어 있을 경우 토큰이 파드와 함께 생성되고, 파드가 삭제 될 때 폐기
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"																	
