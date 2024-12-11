	PRC-C-037	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	4. 컨테이너 장치	읽기 전용 모드로 컨테이너 루트 파일 시스템 마운트	3	기본적으로 컨테이너의 루트 파일 시스템은 읽기/쓰기 모드로 마운트되나, 읽기 전용 모드로 설정할 경우 컨테이너 내에서 파일이나 디렉토리가 무단으로 수정되는 것을 방지하여 컨테이너의 무결성을 유지할 수 있으므로 읽기 전용 모드로 컨테이너 루트 파일 시스템 마운트 여부를 점검	ㅇ		ㅇ	"* 개별 POD에서 'securityContext.readOnlyRootFilesystem' 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|securityContext.readOnlyRootFilesystem:{.securityContext.readOnlyRootFilesystem}{''}{end}"""	"* 양호 - 'readOnlyRootFilesystem'이 true로 설정되어 있을 경우
* 취약 - 'readOnlyRootFilesystem'이 false로 설정되어 있을 경우

※ default : false
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'ReadonlyRootfs' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: ReadonlyRootfs={{ .HostConfig.ReadonlyRootfs }}' 
>> - container_id1: ReadonlyRootfs=false
>> - container_id2: ReadonlyRootfs=true"	"* 양호: 'ReadonlyRootfs'가 true로 설정되어 있을 경우
* 취약: 'ReadonlyRootfs'가 false로 설정되어 있을 경우

※ 기본값 : false"													
