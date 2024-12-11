	PRC-C-016	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	API 사용시 서비스 계정 토큰 검증 여부	3	인증 토큰 검증 시, 서비스 계정에 존재하는지를 검증하지 않을 경우, 서비스 계정 삭제 후에도 인증토큰을 사용할 수 있으므로 서비스 계정 토큰 검증 여부를 점검	ㅇ			"* API 프로세스 또는 설정파일을 통해 ""service-account-lookup"" 설정을 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E service-account-lookup | grep -v grep 
  - (방법2) $ grep -E ""service-account-lookup"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""service-account-lookup"" "	"* 양호 - 'service-account-lookup'가 true로 설정되어 있거나, 존재하지 않을 경우
* 취약 - 'service-account-lookup'가 false로 설정되어 있을 경우

※ Default : true"																	
