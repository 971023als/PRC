	PRC-C-035	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	4. 컨테이너 장치	컨테이너 내 시스템 디렉터리 마운트	4	"호스트 시스템 디렉토리가 읽기, 쓰기 모드로 컨테이너 볼륨으로 마운트될 경우, 컨테이너에서 호스트 시스템으로의 침해가 발생될 수 있으므로, 시스템 디렉터리에 읽기, 쓰기 모드로 마운트 여부를 점검

* /boot, /dev, /etc, /lib, /proc, /sys, /usr"	ㅇ		ㅇ	"*시스템 디렉터리('/boot', '/dev', '/etc', '/lib', '/proc', '/sys', '/usr')의 마운트 여부 확인

* (방법) kubectl 명령어를 사용하여 볼륨 마운트 현황 확인
> $ kubectl get pod <POD이름> -n [네임스페이스] -o jsonpath='{range .spec.containers[*]}{.name} : [{range .volumeMounts[*]}{.mountPath}, {end}]{""\n""}{end}'
>> container_name_1 : [/etc, /var]
>> container_name_2 : [/tmp, /home, /usr]"	"* 양호 - 'volumeMounts'에 시스템 디럭터리가 마운트 되어 있지 않은 경우
* 취약 - 'volumeMounts'에 시스템 디럭터리가 마운트 되어 있는 경우

※ '/boot', '/dev', '/etc', '/lib', '/proc', '/sys', '/usr'
※ 'kube-system' 네임스페이스에 포함된, 쿠버네티스 마스터 컴포넌트(API Server, Scheduler, Controller-manager 등), 시스템 애드온(DNS 서비스, 대시보스, 리소스 메트릭 서버 등) 등 기타 시스템(로그 수집기, 모니터링 에이전트 등)의 경우 대상에서 제외 (단, 'kube-public'은 포함)"			"**시스템 디렉터리('/boot', '/dev', '/etc', '/lib', '/proc', '/sys', '/usr')의 마운트 여부 확인**

* (방법) docker 명령어를 사용하여 볼륨 마운트 현황 확인
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Volumes={{ .Mounts }}'
>> - container_id1: Volumes=[{/var/lib:/data1}]
>> - container_id2: Volumes=[{/var/lib/docker/volumes/volume2:/data2},{/var/lib/docker/volumes/volume3:/data3}]"	"* 양호: 시스템 디렉터리가 마운트 되어 있지 않은 경우
* 취약: 시스템 디렉터리가 마운트 되어 있는 경우"													
