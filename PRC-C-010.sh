	PRC-C-010	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	3. 로그 관리	휘발성 경로 내 로그 파일 저장 여부 확인	3	휘발성 경로에 로그 파일이 저장될 경우, 시스템 재시작 시 로그가 삭제될 수 있으므로, 로그파일 위치를 휘발성 위치가 아닌 곳으로 변경해서 저장하는지 점검	ㅇ	ㅇ		"* API 서버 설정 파일(kube-apiserver.yaml) 또는 프로세스에서 감사 로그 경로 설정 여부를 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E audit-log-path | grep -v grep 
  - (방법2) $ grep -E ""audit-log-path"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""audit-log-path"" "	"* 양호 - 'audit-log-path'가 존재하며, 해당 경로가 비휘발성 경로에 저장될 경우
* 취약 - 'audit-log-path'가 존재하지 않거나, 휘발성 경로(/tmp, /var/tmp, /run, /dev/shm, /dev/pts 등)에 저장하는 경우"	"* kubelet 서비스 설정파일을 통해 ""log-file"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""--log-file""
  - (방법2) $ grep -q ""log-file"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""log-file"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""log-file"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""log-file"" ""/var/lib/kubelet/config.yaml"""	"* 양호 - log-file 설정이 존재하며, 해당 경로가 비휘발성 경로에 저장될 경우 (단, log-file 설정이 존재하지 않을 경우, 관련 로그파일이 systemd, journal에 의해 저장되고, 별도 관리 되고 있을 경우 양호)
* 취약 - log-file 설정이 존재하지 않거나, 휘발성 경로(/tmp, /var/tmp, /run, /dev/shm, /dev/pts 등)에 저장하는 경우"															
