	PRC-C-008	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	2. 서비스 관리	서비스 바인딩 주소의 적절성	4	Controller Manager, Scheduler에 무단 접근 가능할 경우, 클라스터의 동작을 수정 또는 변경하거나, 클러스터의 정보 유출, 리소스 임의 활용 등 악성행위가 수행 가능함에 따라, 사전 정의된 주소에서만 접근 가능하도록 제한하는지를 점검	ㅇ			"* 스케줄러(scheduler.conf), 컨트롤러 관리자(controller-manager.conf) 설정 파일() 또는 관련 프로세스에서 매개변수 확인

  - (방법1) $ ps -ef | grep scheduler | grep -E bind-address | grep -v grep 
                  ps -ef | grep controller-manager | grep -E bind-address | grep -v grep 
  - (방법2) $ grep -E ""bind-address"" ""/etc/kubernetes/manifests/kube-scheduler.yaml""
                  grep -E ""bind-address"" ""/etc/kubernetes/manifests/kube-controller-manager.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""bind-address"" 
                  kubectl get pods -n kube-system -l component=kube-controller-manager -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""bind-address"" "	"* 양호 - 'bind-address'가 127.0.0.1 또는 신뢰구간에 위치한 IP로 설정되어 있을 경우
* 취약 - 'bind-address'가 0.0.0.0으로 설정되어 있을 경우"																	
