	PRC-C-022	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	1. 컨테이너 런타임	레지스트리 연결 구간에 대한 보안 프로토콜 사용	2	"레지스트리 연결 시, 통신구간 암호화가 적용되지 않을 경우 중간자 공격 등에 의한 리소스 위변조 등이 발생될 수 있으므로 레지스트리 연결 구간에 암호화 통신 여부를 점검

"			ㅇ					"**Insecure Registry는 보안 프로토콜이 적용되지 않은 레지스트리를 사용할 때 설정하며, Insecure Registry에 레지스트리를 적용할 경우 비암호화 통신(HTTP)을 통해 레지스트리와 통신 가능**

* (방법1) PS 명령어를 사용하여 Docker 데몬(dockerd) 명령줄의 'insecure-registry' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep ""insecure-registry"" | grep -v grep
>> root     12345   1     0   Jul09   ?   00:00:00 dockerd --insecure-registry=test.registry.com

* (방법2) docker 설정파일(/etc/docker/daemon.json)을 열어 'insecure-registries' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep ""insecure-registries""
>> ""insecure-registries"": [""my.insecure.registry.com""]

* (방법3) 아래 명령어 실행 후, '.RegistryConfig.InsecureRegistryCIDRs' 값 확인
> $ docker info --format 'Insecure Registries: {{.RegistryConfig.InsecureRegistryCIDRs}}'
>> Insecure Registries: [test.registry.com]"	"* 양호: Insecure Registry가 사용되고 있지 않을 경우 (단, insecure registry 주소가 localhost(127.0.01)일 경우 양호, 레지스트리가 https 만 제공할 경우 양호)
* 취약: Insecure Registry가 사용되고 있을 경우
"													
