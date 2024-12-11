	PRC-V-035	기술적 보안	OS 가상화 시스템	4. 가상 네트워크 관리	1. 가상 네트워크 관리	가상스위치 무차별(Promiscuous) 모드 정책 활성화	3	"가상스위치에 무차별(Promiscuous) 모드가 활성화된 경우, 해당 가상스위치는 다른 스위치로 전달되는 네트워크 트래픽을 모니터링 할 수 있으므로, 무차별(Promiscuous) 모드 비활성화(false)를 점검

* Promiscuous 모드 : 자신에게 직접 전달되지 않은 모든 네트워크 트래픽 패킷을 수신하는 기능"	-	ㅇ	-	-	"* 아래 방법을 통해 가상스위치 Promiscuous 모드 조회

    1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
       $ esxcli network vswitch standard policy security get --vswitch-name=[가상스위치 이름]
    2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       #  ""네트워킹"" -> [가상스위치] -> ""보안정책"" 설정 확인"	"* 양호 : 가상스위치에 Promiscuous 모드 정책 설정이 거부(false)일 경우
* 취약 : 가상스위치에 Promiscuous 모드 정책 설정이 허용(true)일 경우"
