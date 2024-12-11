	PRC-C-015	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	API 사용에 대한 취약한 인증 모드 적용	3	클라우드 시스템에서 제공하는 API에 대한 인증이 적용되지 않을 경우 비인가자에 의해 API가 무단 사용됨으로써 시스템 설정 변경, 가상 머신 제어 등의 보안 위협이 발생 될 수 있으므로, API 사용에 대한 인증 모드의 적절성을 점검	ㅇ	ㅇ		"* API 프로세스 또는 설정파일을 통해 ""authorization-mode"" 설정을 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E authorization-mode | grep -v grep 
  - (방법2) $ grep -E ""authorization-mode"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""authorization-mode"" 

※ (참고) 인증모드 종류
  - Node: kubelets이 자신에게 할당된 API 서버 리소스에 대한 액세스 권한을 제한적으로 부여받습니다.
  - ABAC (Attribute-Based Access Control): 속성을 기반으로 정책(예 : 사용자, 리소스 유형, 네임스페이스 등)을 설정하여 API 리소스에 대한 액세스를 허용 또는 거부
  - RBAC (Role-Based Access Control): 사용자 또는 사용자 그룹에 역할을 할당하여 API 리소스에 대한 액세스를 제어
  - Webhook: 웹훅 모드를 사용하면 외부 서비스에 권한 확인 요청을 전송(사용자의 권한을 확인 후 요청을 허용하거나 거부)
  - AlwaysAllow: 모든 요청을 허용
  - AlwaysDeny: 모든 요청을 거부"	"* 양호 - 'authorization-mode'가 webhook, RBAC 등으로 설정되어 있을 경우
* 취약 - 'authorization-mode'가 존재하지 않거나, AlwaysAllow로 설정되어 있을 경우

※ Default : authorization-mode=AlwaysAllow"	"* kubelet 프로세스 또는 설정파일을 통해 ""authorization-mode"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""authorization-mode""
  - (방법2) $ grep -q ""authorization-mode"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""authorization-mode"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""authorization-mode"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""authorization-mode"" ""/var/lib/kubelet/config.yaml""
※ (참고) 인증모드 종류
  - Node: kubelets이 자신에게 할당된 API 서버 리소스에 대한 액세스 권한을 제한적으로 부여받습니다.
  - ABAC (Attribute-Based Access Control): 속성을 기반으로 정책(예 : 사용자, 리소스 유형, 네임스페이스 등)을 설정하여 API 리소스에 대한 액세스를 허용 또는 거부
  - RBAC (Role-Based Access Control): 사용자 또는 사용자 그룹에 역할을 할당하여 API 리소스에 대한 액세스를 제어
  - Webhook: 웹훅 모드를 사용하면 외부 서비스에 권한 확인 요청을 전송(사용자의 권한을 확인 후 요청을 허용하거나 거부)
  - AlwaysAllow: 모든 요청을 허용
  - AlwaysDeny: 모든 요청을 거부"	"* 양호 - ""authorization-mode"" 값이 webhook, RBAC 등으로 설정되어 있을 경우
* 취약 - ""authorization-mode"" 값이 존재하지 않거나, AlwaysAllow로 설정되어 있을 경우

※ Default : authorization-mode=AlwaysAllow"															
