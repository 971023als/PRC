	PRC-C-031	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	2. 컨테이너 권한 관리	컨테이너의 관리자 권한 실행	4	컨테이너가 관리자(root)로 실행될 경우, 컨테이너 내부에서의 공격이 호스트 시스템에 영향을 미칠 수 있으므로 일반 사용자 계정으로 컨테이너 실행 여부를 점검	ㅇ		ㅇ	"* 개별 POD에서 runAsUser 또는 runAsNonRoot 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}{'|'}securityContext.runAsUser:'{.securityContext.runAsUser}'|securityContext.runAsNonRoot:'{.securityContext.runAsNonRoot}'{''}{end}""



"	"* 양호 - ''runAsNonRoot=true' & 'runAsUser=루트가 아닌 값',  'runAsNonRoot' 미지정 & 'runAsUser=루트가 아닌 값', 
* 취약 - 'runAsNonRoot=false' & 'runAsUser' 미지정, 'runAsNonRoot=false' & 'runAsUser=0', 'runAsNonRoot' 미지정 & 'runAsUser' 미지정

※ default : runAsNonRoot=false, runAsUser=0
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, uid 확인**

* (방법) 
> $ docker ps --quiet | xargs -I{} sh -c ""docker exec {} cat /proc/1/status | grep '^Uid:' | awk '{print \$3}'""
>> 0

"	"* 양호: 일반 유저 계정으로 컨테이너를 실행한 경우
* 취약: 관리자 계정(root)으로 컨테이너를 실행한 경우
"													
