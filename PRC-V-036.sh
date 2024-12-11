	PRC-V-036	기술적 보안	OS 가상화 시스템	4. 가상 네트워크 관리	1. 가상 네트워크 관리	가상스위치 위조전송(Forged Transmits) 모드 정책 활성화	3	"가상스위치에 위조전송(Forged Transmits) 모드가 설정되어 있을 경우, 네트워크 스니핑, 데이터 유출 등의 보안 위협이 발생될 수 있으므로 위조 전송모드 비활성화(false)를 점검

* Forged Transmits(위조전송) 모드 : 가상 스위치가 수신하는 모든 트래픽을 연결된 모든 가상 NIC에게 전송하는 기능"	-	ㅇ	-	-	"* 아래 방법을 통해 가상스위치 위조전송 모드 조회

    1. (방법1) SSH를 통해 ESXi 접속 후, 다음 명령어 실행
       $ esxcli network vswitch standard policy security get --vswitch-name=[가상스위치 이름]
    2. (방법2) vSphere Client(ESXi) 접속 후, 다음 메뉴에 접근하여 확인(vSphere Client 버전에 따라, 메뉴 명칭은 달라질 수 있음)
       #  ""네트워킹"" -> [가상스위치] -> ""보안정책"" 설정 확인"	"* 양호 : Forged Transmits 설정이 거부(false)일 경우
* 취약 : Forged Transmits 설정이 허용(true)일 경우"
