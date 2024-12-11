	PRC-C-038	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	4. 컨테이너 장치	마운트 전파 모드(Mount Propagation Mode) 공유 설정	3	마운트 전파(Mount Propagation) 모드가 공유로 설정될 경우, 컨테이너 내부에서 마운트 또는 언마운트 작업이 호스트에 전파되고,  호스트에서의 변경 사항이 다른 컨테이너에 전파될 수 있으므로 마운트 전파 모드의 공유 설정 여부를 확인	ㅇ		ㅇ	"*아래 명령어 실행 후, 'mountPropagation' 설정 확인 후, 'Bidirectional' 존재 여부 확인

  $ kubectl get pod [POD] -n [namespaces] -o jsonpath=""{range .spec.containers[*]}{.name}|securityContext.mountPropagation:{.securityContext.mountPropagation}{''}{end}""

* (참고) Propagation 종류
    - None: 컨테이너 내부의 마운트 변경을 호스트 또는 다른 컨테이너와 공유하지 않음
    - HostToContainer: 컨테이너와 호스트 사이의 마운트 변경을 공유하며, 호스트에서의 마운트 변경이 컨테이너에도 즉시 반영. 다만, 컨테이너에서의 마운트 변경은 호스트에 영향을 주지 않음
    - Bidirectional: 컨테이너와 호스트 사이의 마운트 변경을 공유하며, 컨테이너 사이에서도 마운트 변경을 공유"	"* 양호 - 'mountPropagation' 설정에 마운트 전파 모드가 'Bidirectional' 이 아닐 경우
* 취약 - 'mountPropagation' 설정에 마운트 전파 모드가 'Bidirectional' 일 경우

※ default : None
※ Bidirectional : 마운트 포인트가 호스트와 컨테이너 사이에서 양방향으로 전파
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'Propagation' 설정 확인 후, 'shared' 존재 여부 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}'
>> - container_id1: Propagation=""rprivate""  
>> - container_id2: Propagation=""rprivate"" ""shared""
>> - container_id3: Propagation=""private"" ""slave""

* (참고) Propagation 종류
    - private: 마운트 포인트에 발생한 변경 사항은 해당 마운트 포인트에만 영향을 미침 ( 마운트 포인트에 대한 변경 사항이 다른 마운트 포인트에 전파되지는 않음)
    - rprivate(recursive private): private과 비슷하게 동작하나, 마운트 포인트 및 하위 모든 마운트 포인트에 대한 변경 사항이 해당 마운트 포인트에만 영향을 미침
    - shared: 마운트 포인트에 발생한 변경 사항은 동일한 마운트를 공유하는 모든 마운트 포인트에 전파
    - rshared(recursive shared) : 지정된 마운트 포인트 및 그 아래의 모든 마운트 포인트에 대해 변경 사항이 동일한 마운트를 공유하는 모든 마운트 포인트에 전파
    - slave: 마운트 포인트는 원본 마운트에서 변경 사항을 받아들이지만, 해당 마운트 포인트에서 발생한 변경 사항은 원본 마운트에 전파되지 않음
    - rslave(recursive slave): 지정된 마운트 포인트 및 그 아래의 모든 마운트 포인트에 대해 원본 마운트에서 변경 사항을 받아들이나, 해당 마운트 포인트에서 발생한 변경 사항은 원본 마운트에 전파되지 않음"	"* 양호: 'Propagation' 설정에 마운트 전파 모드(shared)가 활성화되지 않은 경우
* 취약: 'Propagation' 설정에 마운트 전파 모드(shared)가 활성된 경우"													
