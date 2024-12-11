	PRC-C-018	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	kubelet의 iptables 동기화 설정	4	Kubelet의 iptables 동기화 설정이 적절히 이루어지지 않은 경우, 네트워크 트래픽이 예상치 못한 방식으로 라우팅될 수 있으므로, iptables 동기화 설정 여부를 점검		ㅇ				"* kubelet 프로세스 또는 설정파일을 통해 ""make-iptables-util-chains"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""make-iptables-util-chains makeIPTablesUtilChains""
  - (방법2) $ grep -q ""make-iptables-util-chains makeIPTablesUtilChains"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""make-iptables-util-chains makeIPTablesUtilChains"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""make-iptables-util-chains makeIPTablesUtilChains"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""make-iptables-util-chains makeIPTablesUtilChains"" ""/var/lib/kubelet/config.yaml"""	"* 양호 - ""make-iptables-util-chains"" 또는 ""makeIPTablesUtilChains"" 값이 존재하지 않거나, true로 설정되어 있을 경우
* 취약 - ""make-iptables-util-chains"" 및 ""makeIPTablesUtilChains"" 값이 false로 설정되어 있을 경우

※ Default : make-iptables-util-chains=true"															
