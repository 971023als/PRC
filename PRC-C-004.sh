	PRC-C-004	기술적 보안	"컨테이너
가상화
시스템"	1. 인증 및 접근제어	2. 인증 정책 설정	취약한 인증 방식 사용	5	취약한 인증방식(토큰 인증파일)을 사용할 경우, 인증정보 유출, 재사용 등의 보안 위협이 발생될 수 있으므로, 취약한 인증 방식 사용 여부를 점검	ㅇ			"* API 서버 설정 파일(kube-apiserver.yaml) 또는 프로세스에서 인증관련 매개변수 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E token-auth-file | grep -v grep 
  - (방법2) $ grep -E ""token-auth-file"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {'
'}{end}"" | grep -E ""token-auth-file""

* 참고사항
 - 토큰 기반 인증 설정 (--authentication-token-webhook-config-file)
 - 인증서 기반 인증 설정 (--client-ca-file, --tls-cert-file, --tls-private-key-file)
 - 서비스 어카운트 토큰 설정 (--service-account-key-file, --service-account-lookup, --service-account-signing-key-file, --service-account-issuer, --service-account-api-audiences)
 - 웹훅 토큰 인증 설정 (--authentication-token-webhook-cache-ttl, --authentication-token-webhook-config-file)
 - 기본 인증 설정 (--basic-auth-file)
 - 토큰 인증 파일 설정 (--token-auth-file)"	"* 양호 - 'token-auth-file'에 매핑된 token 경로가 존재하지 않을 경우
* 취약 - 'token-auth-file'에 매핑된 token 경로가 존재할 경우

※ kubernetes 1.24 버전 이상 부터는 양호"																	
