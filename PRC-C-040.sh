	PRC-C-040	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	4. 컨테이너 장치	불필요한 AUFS 스토리지 드라이버 사용	3	AUFS 스토리지 드라이버를 사용할 경우, 유지보수 문제, 안정성 문제 등을 일으킬 수 있으므로, AUFS 스토리지를 불필요하게 사용하는지를 점검		ㅇ	ㅇ			"* (방법) Containerd 설정 파일(config.toml)을 확인하여 AUTFS 스토리지 드라이버 사용여부 확인

 $ sudo cat /etc/containerd/config.toml | grep 'snapshotter'"	"* 양호 - AUFS 스토리지 드라이버를 사용하지 않을 경우
* 취약 - AUFS 스토리지 드라이버를 사용하고 있을 경우"	"**Storage Driver는 컨테이너의 파일 시스템을 관리하는데 사용되는 드라이버로, 컨테이너의 파일 시스템을 호스트의 파일 시스템과 연결 후, 컨테이너가 생성, 실행, 종료될 때 파일 시스템의 변경을 처리하며, 스토리지 드라이버는 AUFS, OverlayFS, Device Mapper, BTrfs, ZFS 등이 존재**

* (방법) docker 명령어를 사용하여 'Driver' 설정 값 확인
>  $ docker info --format 'Storage Driver: {{ .Driver }}'
>> Storage Driver: aufs"	"* 양호 - AUFS 스토리지 드라이버를 사용하지 않을 경우
* 취약 - AUFS 스토리지 드라이버를 사용하고 있을 경우"													
