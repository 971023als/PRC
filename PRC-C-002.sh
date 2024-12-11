	PRC-C-002	기술적 보안	"컨테이너
가상화
시스템"	1. 인증 및 접근제어	1. 서비스 어카운트 관리	Role(ClusterRole)의 과도한 권한 부여	4	Role 또는 ClusterRole에 와일드카드(*)가 부여되어 있을 경우, 모든 리소스에 대한 모든 권한이 부여되므로 와일드 카드 부여 여부를 점검	ㅇ			"* Clusterrole, Role 목록 확인 후, 와일드카드 적용 여부 확인

  $ kubectl get roles --all-namespaces -o=jsonpath=""{range .items[*]}{'Role: '}{.metadata.name}{' - Namespace: '}{.metadata.namespace}{''}{range .rules[*]}{'Verbs: '}{.verbs}{''}{'APIGroups: '}{.apiGroups}{}{'Resources: '}{.resources}{''}{end}{'
'}{end}"""	"* 양호 - Role 및 ClusterRole의 verbs, apigroups, resources 전체에 와일드 카드(*)가 불필요하게 부여되어 있지 않은 경우
* 취약 - Role 및 ClusterRole의 verbs, apigroups, resources 전체에 와일드 카드(*)가 불필요하게 부여 되어 있는 경우

※ 단, cluster-admin에 대해서는 제외"																	
