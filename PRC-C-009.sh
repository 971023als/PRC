	PRC-C-009	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	3. 로그 관리	시스템 주요 이벤트 로그 설정 미흡	3	시스템 주요 이벤트 로그가 설정되어 있지 않을 경우 시스템 문제 발생 시 보안, 성능 등의 이슈를 파악하기 어려움으로 시스템, 가상머신, 보안 등의 로그가 저장되도록 설정되어 있는지를 점검	ㅇ	ㅇ	ㅇ	"* API 서버 설정 파일(kube-apiserver.yaml) 또는 프로세스에서 감사 로그 경로 설정 여부를 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E audit-log-path | grep -v grep
  - (방법2) $ grep -E ""audit-log-path"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""audit-log-path"" 


* API 서버 설정 파일(kube-apiserver.yaml) 또는 프로세스에서 감사 로그 정책 설정 여부를 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E audit-policy-file | grep -v grep
  - (방법2) $ grep -E ""audit-policy-file"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""audit-policy-file"" "	"* 양호 - 'audit-log-path', 'audit-policy-file'가 설정되어 있을 경우
* 취약 - 'audit-log-path', 'audit-policy-file'가 미설정 되어 있을 경우"	"* kubelet 서비스 설정파일을 통해 ""v"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""--v""
  - (방법2) $ grep -q ""--v"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""--v"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""--v"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""--v"" ""/var/lib/kubelet/config.yaml"""	"* 양호 - v 플래그가 3 이상으로 설정되어 있을 경우
* 취약 - v 플래그가 3 미만으로 미설정 되어 있을 경우

※ Default : --v=0"	"**로그 설정 레벨(log-level)은 Docker의 로깅 시스템에서 사용되는 설정(trace, debug, info, warn, error, fatal)으로 관련 설정 존재 여부를 확인하며, 기본 log-level은 info로 설정**

* (방법1) PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'log-level' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""log-level"" | grep -v grep
>> root     12345   1     0   Jul09   ?   00:00:00 dockerd --log-level=info

* (방법2) docker 설정파일(/etc/docker/daemon.json)을 열어 'log-level' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""log-level""
>>""log-level"": ""info""

* (방법3) 아래 명령어 실행 후, 'log-level' 값 확인
> $ docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' 
>>bridge: map[com.docker.network.bridge.default_bridge\:true com.docker.network.bridge.enable_icc\:true log-driver\:json-file log-level\:info]"	"* 양호: 로그 기록 정책이 내부 정책에 부합하게 설정되어 있는 경우 (없을 경우 info 이상)
* 취약: 로그 기록 정책이 내부 정책에 부합하게 설정되지 않은 경우

※ Default : log-level=info"													
