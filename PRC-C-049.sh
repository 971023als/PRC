	PRC-C-049	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	6. 컨테이너 리소스	PID cgroup 제한 설정	2	PID cgroup을 제한하지 않을 경우, 포크 폭탄(Fork Bomb)에 의한 시스템 장애가 발생될 수 있으므로 PID cgroup을 통한 최대 프로세스 개수 제한 여부를 점검			ㅇ					"**아래 명령어 실행 후, 'HostConfig.PidsLimit' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: PidsLimit={{ .HostConfig.PidsLimit }}'
>> - container_id1: PidsLimit=256      # 256개의 프로세스로 제한
>> - container_id2: PidsLimit=0  # 제한이 없음
"	"* 양호: 'HostConfig.PidsLimit' 값이 적절하게 설정되어 있을 경우
* 취약: 'HostConfig.PidsLimit' 값이 0또는 -1일 경우

※ default : 0"													
