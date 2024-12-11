	PRC-C-033	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	3. 컨테이너 가용성	컨테이너의 재시작 정책 설정의 적절성	2	컨테이너의 재시작 정책이 설정되지 않을 경우, 장애 발생 시 시스템이 복구되지 않아 서비스 가용성에 영향을 끼칠 수 있으므로 재시작 정책 설정 여부를 점검	ㅇ		ㅇ	"* 개별 POD에서 runAsUser 또는 restartPolicy 설정 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|spec.restartPolicy:{.spec.restartPolicy}{''}{end}"""	"* 양호 - 'restartPolicy'가 'Always', 'OnFailure'로 설정되어 있는 경우
* 취약 - 'restartPolicy'가 'Never'로 설정되어 있는 경우

※ default : Always
※ 다만, 일회성 서비스(배치, 크론 등)의 경우 Never 사용 가능
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'HostConfig.RestartPolicy.Name' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: RestartPolicyName={{ .HostConfig.RestartPolicy.Name }} MaximumRetryCount={{ .HostConfig.RestartPolicy.MaximumRetryCount }}'
>> - container_id1: RestartPolicyName=unless-stopped MaximumRetryCount=0  # unless-stopped : 컨테이너가 수동으로 정지될 때까지 재시작되지 않음
>> - container_id2: RestartPolicyName=always MaximumRetryCount=0 # 컨테이너가 종료되면 항상 재시작
>> - container_id3: RestartPolicyName=on-failure MaximumRetryCount=5 # 컨테이너가 비정상적으로 종료될 때 재시작
>> - container_id3: RestartPolicyName=no MaximumRetryCount=0 # 컨테이너가 비정상적으로 종료되었을 때 재시작되지 않음"	"* 양호: 컨테이너 재시작 정책이 'always', 'on-failure' 등 재시작하도록 설정되어 있고, 재시작 횟수가 적절하게 설정되어 있는 경우
* 취약: 컨테이너 재시작 정책이 'no'로 설정되어 있거나, 재시작 횟수(MaximumRetryCount)가 0으로 설정되어 있는 경우"													
