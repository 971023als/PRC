	PRC-C-034	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	3. 컨테이너 가용성	컨테이너 HEALTHCHECK	2	"서비스 가용성 확보를 위해 이미지 내 또는 컨테이너 실행 시 HEALTHCHECK 명령 포함여부를 확인

※ HEALTHCHECK는 컨테이너 내의 애플리케이션의 상태를 주기적으로 검사하는데 사용되는 명령어나 구성으로, 이를 통해 컨테이너의 정상 동작 상태 여부를 판별 가능"			ㅇ					"**아래 명령어 실행 후, 'State.Health.Status' 설정 확인**
> $ docker ps --quiet | xargs docker inspect --format '{{ .Id }}: Health={{ .State.Health.Status }}'  
>> - container_id1: Health=starting      # 컨테이너가 시작되고 있는 상태로, 아직 헬스 체크가 완료되지 않았거나 체크가 시작되기 전인 경우
>> - container_id2: Health=healthy  # 컨테이너 헬스 체크가 성공적으로 완료되어 정상 상태인 경우
>> - container_id3: Health=unhealthy # 컨테이너 헬스 체크가 실패하거나 오류가 발생하여 비정상 상태인 경우
>> - container_id4: Health=     # 컨테이너 "	"* 양호: 이미지 내 또는 컨테이너 실행 명령줄에 HEALTHCHECK 명령어가 존재하는 경우
* 취약: 이미지 내 또는 컨테이너 실행 명령줄에 HEALTHCHECK 명령어가 존재하지 않는 경우"													
