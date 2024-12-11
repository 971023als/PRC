	PRC-C-050	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	6. 컨테이너 리소스	Ulimit 구성의 적절성	2	"컨테이너는 호스트 시스템의 리소스를 공유하기 때문에, 하나의 컨테이너가 너무 많은 자원을 소비하는 경우 호스트 시스템 가용성에 문제가 발생될 수 있으므로, ulimit 설정을 통해 컨테이너의 자원 제한 여부를 점검

* ulimit(user limit) : 사용자가 생성할 수 있는 프로세스 수, 열 수 있는 파일의 수, 사용할 수 있는 메모리 양 등을 제한하기 위한 명령"			ㅇ					"**""default-ulimit(user limit)""은 Docker 데몬에서 컨테이너 내에서 실행되는 프로세스의 자원(파일 디스크럽터 수, 프로세스 개수 등)에 제한을 지정하는 옵션으로 관련 설정 존재 여부를 확인**

* (방법1) PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'default-ulimit' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""default-ulimit"" | grep -v grep
>> root     12345   1     0   Jul09   ?   00:00:00 dockerd --default-ulimit nofile=1024:2048 --default-ulimit nproc=1000 --default-ulimit fsize=1048576:2097152 --default-ulimit memlock=unlimited:unlimited --default-ulimit core=unlimited

* (방법2) docker 설정파일(/etc/docker/daemon.json)을 열어 'default-ulimit' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""default-ulimit""
>>""default-ulimit"": {
  ""nofile"": ""1024:2048"",
  ""nproc"": ""1000""
}

* (방법3) 아래 명령어 실행 후, 'DefaultUlimit' 값 확인
> docker system info --format '{{.DefaultUlimit}}'
>> map[nofile:1024:2048 nproc:1000:2000 fsize:1048576:2097152 memlock:unlimited:unlimited core:unlimited:unlimited]


* (참고) ""default-ulimit"" 옵션 종류
   - nofile: 컨테이너의 파일 디스크립터 수 제한
   - nproc: 컨테이너의 프로세스 개수 제한
   - fsize: 컨테이너에서 생성되는 파일의 크기 제한
   - memlock: 잠긴 메모리의 최대 크기 제한
   - core: 코어 덤프 파일 크기 제한"	"* 양호: Docker 데몬에 'default-ulimit' 옵션이 존재하거나, 개별 컨테이너에 'ulimit' 옵션이 존재할 경우
* 취약: Docker 데몬에 'default-ulimit' 옵션이 존재않고, 개별 컨테이너에 'ulimit' 옵션이 존재하지 않을 경우

※ default : 기본적으로 'default-ulimit' 옵션 미설정되어있으며, 호스트 시스템의 ulimit 설정을 상속 (ulimit -a)"													
