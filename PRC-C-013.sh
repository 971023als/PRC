	PRC-C-013	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	Anonymous 계정의 API 접속 제한 미비	3	API 서버에 대한 Anonymous 계정 허용 등 부적절한 인증 설정이 되어 있을 경우, 비인가자에 의한 API사용, 인증정보 탈취 등의 위협이 발생될 수 있으므로, API 서버 인증 구성의 적절성을 점검	ㅇ	ㅇ		"* API 프로세스 또는 설정파일을 통해 ""anonymous-auth"" 설정을 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E anonymous-auth | grep -v grep 
  - (방법2) $ grep -E ""anonymous-auth"" ""/etc/kubernetes/manifests/kube-apiserver.yaml"""	"* 양호 - 'anonymous-auth'가 false로 설정되어 있을 경우
* 취약 - 'anonymous-auth'가 존재하지 않거나, true로 설정되어 있을 경우

※ Default : true"	"* kubelet 프로세스 또는 설정파일을 통해 ""anonymous-auth"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""anonymous-auth""
  - (방법2) $ grep -q ""anonymous-auth"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""anonymous-auth"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""anonymous-auth"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""anonymous-auth"" ""/var/lib/kubelet/config.yaml"""	"* 양호 - ""anonymous-auth"" 값이 false로 설정되어 있을 경우
* 취약 - ""anonymous-auth"" 값이 존재하지 않거나, true로 설정되어 있을 경우

※ Default : anonymous-auth=true"															
