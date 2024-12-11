	PRC-C-032	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	3. 컨테이너 가용성	컨테이너의 상태 보존 설정	2	"컨테이너 런타임 데몬이 장애 또는 업데이트로 인한 재시작 발생으로 인한 컨테이너의 가용성 확보를 위해, 컨테이너의 상태를 보존하기 위한 옵션 설정 여부를 점검

※ LiveRestoreEnabled 옵션이 활성화 되어 있을 경우 Docker daemon을 재시작하더라도 실행 중인 컨테이너들은 중지되지 않아 서비스 가용성 확보 가능"			ㅇ					"**Live Restore 옵션은 Docker 컨테이너가 처음 실행될 때의 권한 상태를 유지하도록 하여, 이후에는 권한을 더 얻을 수 없도록 하는 옵션으로 관련 설정 존재 여부를 확인**

* (방법1) PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'live-restore' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""live-restore"" | grep -v grep
>> root     12345   1     0   Jul09   ?   00:00:00 dockerd --live-restore
* (방법2) 아래 명령어 실행 후, 'Storage Driver' 값 확인
> $ docker info --format '{{ .LiveRestoreEnabled }}' 
>> true"	"* 양호: 컨테이너 상태 보존 설정을 위한 Live Restore 설정이 존재하는 경우
* 취약: 컨테이너 상태 보존 설정을 위한 Live Restore 설정이 존재하지 않는 경우

※ 기본값 : 비활성화"													
