	PRC-C-014	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	API 요청 타임아웃 설정	3	API 서버 요청에 대한 제한시간이 과도하게 크게 설정될 경우, API 서버 리소스가 소진되어 서비스 부하가 발생 될 수 있으므로 API 요청 타임아웃 설정 여부를 점검	ㅇ			"* API 프로세스 또는 설정파일을 통해 ""request-timeout"" 설정을 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E request-timeout | grep -v grep 
  - (방법2) $ grep -E ""request-timeout"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""request-timeout"" "	"* 양호 - 'request-timeout'가 설정되어 있지 않거나, 60초 이하로 설정되어 있는 경우
* 취약 - 'request-timeout'가 60초 초과로 설정되어 있는 경우

※ Default : request-timeout=60"																	
