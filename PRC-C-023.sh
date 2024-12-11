	PRC-C-023	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	1. 컨테이너 런타임	Docker의 기본 네트워크 인터페이스(docker0) 사용	3	"Docker가 기본 네트워크 인터페이스(docker0)를 사용할 경우 컨테이너들은 동일한 네트워크 대역을 공유하게되며, 호스트 시스템과 직접적으로 통신하게 되며, ARP Spoofing 및 MAC Flooding 등의 공격에 취약할 수 있으므로, docker0가 아닌 사용자 정의 네트워크 사용 여부를 점검

※ docker0 사용 옵션이 비활성화(false)로 되어 있을 경우 컨테이너는 자동으로 'docker0' 브리지에 연결되지 않아 컨테이너들이 호스트와 네트워크 통신을 할 수 없게되며, 활성화(true) 되어 있을 경우 컨테이너들이 호스트와 네트워크 통신이 가능"			ㅇ					"**아래 명령어 실행 후, 'com.docker.network.bridge.default_bridge' 설정 확인**
> $ docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' 
>> bridge: map[com.docker.network.bridge.default_bridge:true com.docker.network.bridge.enable_icc:true com.docker.network.bridge.enable_ip_masquerade:true com.docker.network.bridge.host_binding_ipv4:0.0.0.0 com.docker.network.bridge.name:docker0 com.docker.network.driver.mtu:1500]
"	"* 양호: 'com.docker.network.bridge.default_bridge' 값이 false일 경우
* 취약: 'com.docker.network.bridge.default_bridge' 값이 true 경우

※ 기본값 : true (활성화)"													
