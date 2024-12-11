	PRC-C-025	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	2. 컨테이너 권한 관리	불필요한 프로파일링 기능 활성화	2	"프로파일링 기능이 활성화 되어 있을 경우, 프로파일링 기능을 통해 시스템 정보 유출이 될 수 있으므로, 업무상 불필요할 경우 프로파일링 기능 활성화 여부를 점검

※ 프로파일링 기능을 통해 서버의 성능 문제를 진단할 수 있으나, 성능 데이터 수집 등을 위해 추가적인 데이터를 수집함에 따라 업무상 불필요할 경우 프로파일링 기능 비활성화 필요"	ㅇ			"* API 서버(kube-apiserver.yaml,), 스케줄러(scheduler.conf), 컨트롤러 관리자(controller-manager.conf) 설정 파일 또는 관련 프로세스에서 매개변수 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E profiling | grep -v grep 
                  ps -ef | grep scheduler | grep -E profiling | grep -v grep 
                  ps -ef | grep controller-manager | grep -E profiling | grep -v grep 
  - (방법2) $ grep -E ""profiling"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
               $ grep -E ""profiling"" ""/etc/kubernetes/manifests/kube-scheduler.yaml""
               $ grep -E ""profiling"" ""/etc/kubernetes/manifests/kube-controller-manager.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""profiling"" 
               $ kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""profiling"" 
               $ kubectl get pods -n kube-system -l component=kube-controller-manager -o jsonpath=""{range .items[]}{.spec.containers[].command} {''}{end}"" | grep -E ""profiling"""	"* 양호 - 'profiling'이 false로 설정되어 있을 경우
* 취약 - 'profiling'이 미설정 되어 있거나, true로 설정되어 있을 경우

※ default : true"																	
