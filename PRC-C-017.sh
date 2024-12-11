	PRC-C-017	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	kubelet 읽기 전용 포트 설정	4	Kubelet의 읽기 전용 포트가 활성화되어 있을 경우, 인증되지 않은 접근이 가능하게 되어 정보 유출 위험이 있으므로, kubelet 읽기 전용 포트 비활성화 여부를 점검		ㅇ				"* kubelet 프로세스 또는 설정파일을 통해 ""read-only-port"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""read-only-port readOnlyPort""
  - (방법2) $ grep -q ""read-only-port readOnlyPort"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""read-only-port readOnlyPort"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""read-only-port readOnlyPort"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""read-only-port readOnlyPort"" ""/var/lib/kubelet/config.yaml"""	"* 양호 - ""read-only-port"" 또는 ""readOnlyPort"" 값이 0으로 설정되어 있을 경우
* 취약 - ""read-only-port"" 및 ""readOnlyPort"" 값이 존재하지 않거나, 0으로 설정되어 있지 않을 경우

※ Default : read-only-port=10255"															
