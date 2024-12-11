	PRC-C-036	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	4. 컨테이너 장치	컨테이너 내 CRI socket 불륨 마운트	4	"CRI(Container Runtime Interface) socket* 볼륨이 마운트된 컨테이너는 컨테이너 내부에서 호스트 시스템의 API에 직접 액세스 가능함에 따라, 호스트 시스템 조작, 시스템 리소스 접근, 컨테이너 간 침입 등의 보안 위협이 발생될 수 있으므로, 컨테이너 내 CRI Socket 볼륨 마운트 여부를 확인

* Docker Socket : /var/run/docker.sock
* containerd Socket : /run/containerd/containerd.sock"	ㅇ		ㅇ	"*CRI Socket 볼륨의 마운트 여부 확인

* (방법) kubectl 명령어를 사용하여 볼륨 마운트 현황 확인
> $ kubectl get pod <POD이름> -n [네임스페이스] -o jsonpath='{range .spec.containers[*]}{.name} : [{range .volumeMounts[*]}{.mountPath}, {end}]{""\n""}{end}'
>> container_name_1 : [/var/run/docker.sock]
>> container_name_2 : [/run/containerd/containerd.sock]"	"* 양호 - 'volumeMounts'에 CRI Socket 볼륨(docker.sock, containerd.sock 등)이 마운트 되어 있지 않은 경우
* 취약 - 'volumeMounts'에 CRI Socket 볼륨(docker.sock, containerd.sock 등)이 마운트 되어 있는 경우

※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**아래 명령어 실행 후, 'com.docker.network.bridge.default_bridge' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Volumes={{ .Mounts }}'
>> - container_id1: Volumes=[]
>> - container_id2: Volumes=Volumes=[{bind  /var/run/docker.sock /var/run/docker.sock  ro false rprivate}]"	"* 양호: 컨테이너 내 docker.sock 볼륨이 마운트 되어 있지 않은 경우
* 취약: 컨테이너 내 docker.sock 볼륨이 마운트 되어 있는 경우

※ Default : docker.sock는 마운트 되지 않음"													
