	PRC-C-041	기술적 보안	"컨테이너
가상화
시스템"	3. 컨테이너 관리	5. 컨테이너 네임스페이스	호스트의 사용자 네임스페이스 공유	3	"사용자 네임스페이스 기능을 사용할 경우 컨테이너 내의 사용자 ID와 그룹 ID를 호스트와 분리할 경우, 컨테이너 내부에서 root 권한을 가진 프로세스가 호스트 시스템에서도 root 권한을 갖지 않도록 하는 등 컨테이너 내부에서 실행되는 프로세스가 호스트 시스템에 불필요한 권한을 갖지 않게 하기 위해, 호스트의 사용자 네임스페이스(User namespaces)를 공유하지 않도록 설정되어 있는지를 점검

* User namespace : 컨테이너 내부와 외부에서 사용자 ID와 그룹 ID를 분리하여, 컨테이너 내에서 root 권한을 가진 프로세스가 호스트 시스템에서도 root 권한을 갖지 않도록 하는 Linux 커널의 기능으로, 비활성화(disabled) 되어 있을 경우, 컨테이너 내의 'root' 사용자가 호스트 시스템의 'root' 사용자와 직접 매핑"			ㅇ					"**아래 명령어 실행 후, 'HostConfig.UsernsMode' 설정 확인**
> $ docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UsernsMode={{ .HostConfig.UsernsMode }}'
>> - container_id1: UsernsMode=host      # 컨테이너가 호스트의 유저 네임스페이스를 공유
>> - container_id2: UsernsMode=default  # 컨테이너가 자체적인 유저 네임스페이스를 사용
>> - container_id3: UsernsMode=container:container_id4 # 컨테이너가 다른 컨테이너의 유저 네임스페이스를 공유

**아래 명령어 실행 후, 'userns-remap' 설정 확인**
> $ docker info --format '{{ .SecurityOptions }}' 
>> [apparmor seccomp profile=default name=userns] # 'name=userns' 포함 시, 'userns-remap' 활성화"	"* 양호 : 'userns-remap' 설정이 활성화되어 있고, 모든 컨테이너에서 UsernsMode가 ""host""가 아닌 경우, 'userns-remap' 설정이 활성화되어 있지 않으나 UsernsMode가 ""host"", ""default'로 설정되어 있는 컨테이너가 존재하지 않을 경우
* 취약 : 'UsernsMode'가 ""host""로 설정된 컨테이너가 존재할 경우, 'userns-remap' 설정이 없고, 'UsernsMode'가 ""host"" 또는 ""default""로 설정되어 있는 컨테이너가 존재할 경우

※ Default : UsernsMode는 별도 지정되지 않으며, 아래 정책을 따라감
 - (userns-remap 비활성화) 컨테이너는 호스트 시스템의 사용자 ID와 그룹ID를 그대로 사용(컨테이너 내의 루트 사용자는 호스트 시스템의 루트 사용자와 동일한 권한)
 - (userns-remap 활성화) 컨테이너는 재매핑된 사용자 ID를 사용(컨테이너 내부의 루트 사용자는 호스트 시스템의 루트 사용자와 다른 권한을 가짐)"													
