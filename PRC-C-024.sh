	PRC-C-024	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	1. 컨테이너 런타임	Default Network Bridge 내 네트워크 트래픽 제한 설정	3	"컨테이너가 기본 bridge 네트워크에 연결될 경우, bridge 네트워크 상의 컨테이너들이 서로 통신을 할 수 있으므로 컨테이너 간 통신을 제한하기 위한 icc(inter-container communication) 옵션 활성화 여부를 점검

※ icc(Inter-Container Communication)는 컨테이너 간의 네트워크 통신을 허용 여부를 결정하는 옵션으로 활성화(true)되어 있을 경우 컨테이너 간의 통신을 허용하며, 비활성화 할경우 컨테이너 간의 통신은 차단되고, host의 iptables 규칙을 통해 추가 설정이 필요"			ㅇ					"**icc(inter-container communication) 옵션 활성화 여부를 확인**

* (방법1)  PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'icc' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""icc"" | grep -v grep
>> --icc=false

* (방법2) docker 설정파일(/etc/docker/daemon.json)을 열어 'icc' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""icc""
>> {
  ""icc"": false
}

* (방법3) 아래 명령어 실행 후, 'com.docker.network.bridge.enable_icc' 값 확인
> $ docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' 
>> bridge: map[com.docker.network.bridge.default_bridge\:true com.docker.network.bridge.enable_icc\:false]

* (참고) icc(inter-container communication)는 Docker 컨테이너 간 통신을 가능하게 하는 옵션으로, 해당 옵션이 활성화되어 있을 경우, 모든 컨테이너들은 'docker0' 브리지 네트워크를 통해 서로 통신할 수 있음(Default : false)"	"* 양호 - ""icc"" 값이 false로 설정되어 있을 경우
* 취약 - icc"" 값이 존재하지 않거나, true로 설정되어 있을 경우

※ 기본값 : true"													
