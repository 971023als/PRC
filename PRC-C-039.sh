	PRC-C-039	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	4. 컨테이너 장치	컨테이너의 불필요한 외부 장치 연결	3	컨테이너에 호스트 장치가 연결되어 있을 경우, 컨테이너는 호스트의 장치 제거 등의 행위를 통해 예측하지 못한 위협을 발생 시킬 수 있으므로 불필요한 장치 연결 비활성화 여부를 점검	ㅇ		ㅇ	"*파드의 볼륨 구성(volumes, volumeMouts)을 확인

  $ kubectl get pod [pod] -n [namespace] -o jsonpath={range .spec.containers[*]}{.name}{'|'}[{range .volumeMounts[*]}{.name}:{.mountPath};{end}]{end}{'|'}[{range .spec.volumes[*]}{.name}:{.hostPath.path}:{.hostPath.type};{end}]"	"* 양호 - 'volumeMounts'에 불필요한 장치가 마운트되어 있지 않을 경우
* 취약 - 'volumeMounts'에 불필요한 장치가 마운트되어 있을 경우"			"**아래 명령어 실행 후, 'HostConfig.Devices' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Devices={{ .HostConfig.Devices }}'
>> - container_id1: Devices=[{PathOnHost:/dev/ttyUSB0 PathInContainer:/dev/ttyUSB0 CgroupPermissions:rwm}]  # '/dev/ttyUSB0' 장치가 컨테이너와 연결
>> - container_id2: Devices=[]  # 컨테이너에 연결된 장치가 없음
>> - container_id3: Devices=abcd1234efgh: Devices=[{PathOnHost:/dev/ttyUSB0 PathInContainer:/dev/ttyUSB0 CgroupPermissions:rwm}, {PathOnHost:/dev/ttyUSB1 PathInContainer:/dev/ttyUSB1 CgroupPermissions:rwm}] # '/dev/ttyUSB0'와 '/dev/ttyUSB1' 장치가 컨테이너와 연결"	"* 양호: 'HostConfig.Devices'에 불필요한 장치가 마운트되어 있지 않을 경우
* 취약: 'HostConfig.Devices'에 불필요한 장치가 마운트되어 있을 경우"													
