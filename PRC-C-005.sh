	PRC-C-005	기술적 보안	"컨테이너
가상화
시스템"	1. 인증 및 접근제어	2. 인증 정책 설정	컨트롤러 별 서비스 계정 자격 증명 사용	3	컨트롤러 매니저의 모든 컨트롤러가 동일한 서비스 계정을 사용할 경우, 단일 컨트롤러의 위협이 다른 컨트롤러에도 영향을 미칠 수 있으므로 각 컨트롤러가 별도의 서비스 계정을 사용하도록 설정되어 있는지를 점검	ㅇ			"* 컨트롤러 매니저 설정 파일(kube-controller-manager.yaml) 또는 프로세스에서 인증관련 매개변수 확인

  - (방법1) $ ps -ef | grep controller-manager | grep -E use-service-account-credentials | grep -v grep
  - (방법2) $ grep -E ""use-service-account-credentials"" ""/etc/kubernetes/manifests/kube-controller-manager.yaml"""	"* 양호 - 'use-service-account-credentials'가 true로 설정되어 있을 경우
* 취약 - 'use-service-account-credentials'가 false로 설정되어 있을 경우

* 디폴트 : false"																	
