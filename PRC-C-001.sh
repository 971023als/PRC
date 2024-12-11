	PRC-C-001	기술적 보안	"컨테이너
가상화
시스템"	1. 인증 및 접근제어	1. 서비스 어카운트 관리	불필요한 클러스터 관리자 역할 부여	5	클러스터 관리자(cluster-admin) 역할이 부여되어 있을 경우, 리소스 조작, 민감정보 조작 등 모든 리소스 조작에 대한 권한이 부여됨에 따라, 사용자, 그룹, 서비스 계정(service account)에 불필요한 클러스터 관리자(cluster-admin) 역할 부여 여부를 점검	ㅇ			"* Clusterrolebinding 목록 확인 후, cluster-admin 역할이 부여 여부 확인

  $ kubectl get clusterrolebindings -o=custom-columns='NAME:.metadata.name','ROLE:.roleRef.name','KIND:.subjects[*].kind','NAME:.subjects[*].name','NAMESPACE:.subjects[*].namespace' | awk '/cluster-admin/'
"	"* 양호 - 사용자, 그룹, 서비스 계정(service account)에 불필요한 클러스터 관리자(cluster-admin) 역할이 부여되어 있지 않은 경우
* 취약 - 사용자, 그룹, 서비스 계정(service account)에 불필요한 클러스터 관리자(cluster-admin) 역할이 부여되어 있는 경우"																	
