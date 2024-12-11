	PRC-C-021	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	1. 컨테이너 런타임	데몬의 사용자 영역(userland) 프록시 사용	3	"사용자 영역(userland) 프록시는 컨테이너와 호스트 또는 다른 컨테이너 사이의 네트워크 통신을 가능하게 하는데 사용되나, 사용자 영역 프록시를 사용할 경우 시스템 부하 등의 보안 위협이 발생될 수 있으므로 사용자 영역(userland) 프록시 사용 여부를 점검

※ userland-proxy : 호스트와 컨테이너 간의 포트 포워딩을 담당하는 컴포넌트"			ㅇ					"* (방법1) PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'userland-proxy' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""userland-proxy"" | grep -v grep
>> root     12345   1     0   Jul09   ?   00:00:00 dockerd --userland-proxy
* (방법2) docker 설정파일(/etc/docker/daemon.json)을 열어 'userland-proxy' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""userland-proxy""
>> ""userland-proxy"": true,"	"* 양호: Userland Proxy 설정이 false로 설정되어 있는 경우
* 취약: Userland Proxy 설정이 존재하지 않거나, true로 설정되어 있는 경우

※ 기본값 : true (활성화)"													
