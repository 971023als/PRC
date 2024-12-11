	PRC-C-020	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	1. 컨테이너 런타임	실험적 기능 비활성화	3	실험적 기능 설정이 적용 되어 있을 경우 안정적이지 않은 기능이 활성화되어 시스템 안정성에 영향일 끼칠 수 있으므로, 실험적 기능 비활성화 여부를 점검			ㅇ					"**실험적 기능('.Server.Experimental' 옵션) 활성화 여부 확인**

* (방법1) docker 명령어를 사용하여 'Server.Experimental' 설정 값 확인
> $ docker info --format '{{ .Server.Experimental }}'
>> false

* (방법2) docker 설정파일(/etc/docker/daemon.json)을 열어 'experimental' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""experimental""
>> ""experimental"": true"	"* 양호: 실험적 기능이 비활성화 되어 있는 경우
* 취약: 실험적 기능이 활성화 되어 있는 경우

※ 기본값 : false (비활성화)"													
