	PRC-C-048	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	6. 컨테이너 리소스	cgroup 사용 확인	2	컨테이너가 리소스를 과도하게 사용하는 것을 방지하기 위해, CPU, 메모리, I/O 제한 설정이 적용된 cgroup(control groups) 사용 여부를 점검			ㅇ					"**아래 명령어 실행 후, 'HostConfig.CgroupParent' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: CgroupParent={{ .HostConfig.CgroupParent }}'
>> - container_id1: CgroupParent=      #  컨테이너가 독립적인 cgroup을 가지고 있음
>> - container_id2: CgroupParent=system.slice  # 컨테이너가 호스트 시스템의 system.slice cgroup에 속해 있음
>> - container_id3: CgroupParent=docker # 컨테이너가 Docker 데몬의 docker cgroup에 속해 있음"	"* 양호: 'HostConfig.CgroupParent' 값이 'docker' 등으로 설정되어 있을 경우
* 취약: 'HostConfig.CgroupParent' 값이 존재 하지 않을 경우"													
