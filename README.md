# Kubernetes 클러스터 관리자 역할 점검 스크립트

이 Bash 스크립트는 Kubernetes 환경에서 불필요한 `cluster-admin` 역할이 부여된 사용자, 그룹 및 서비스 계정을 점검하고 결과를 CSV 파일로 저장합니다. 이 스크립트는 보안 감사 및 클러스터 관리자 역할의 최소 권한 원칙을 준수하는 데 유용합니다.

## 주요 기능

1. **ClusterRoleBinding 점검**:
   - Kubernetes의 `cluster-admin` 역할이 할당된 사용자, 그룹 및 서비스 계정을 점검합니다.

2. **CSV 파일로 결과 저장**:
   - 점검 결과를 `output_cluster_admin_roles.csv` 파일에 저장합니다.

3. **결과 로그 출력**:
   - 점검 결과를 터미널에 출력하고, 스크립트 로그를 별도의 파일로 저장합니다.

## 사전 요구 사항

- **Kubernetes 클러스터 액세스 권한**
- **kubectl 설치**:
  - 스크립트는 `kubectl`을 사용하여 클러스터 데이터를 가져옵니다. `kubectl`이 설치되어 있고 클러스터에 올바르게 연결되어 있어야 합니다.

## 사용 방법

1. 이 리포지토리를 클론합니다:

```bash
git clone <repository_url>
```

2. 스크립트를 실행 가능하게 만듭니다:

```bash
chmod +x script_name.sh
```

3. 스크립트를 실행합니다:

```bash
./script_name.sh
```

4. 결과 확인:
   - `output_cluster_admin_roles.csv` 파일에서 점검 결과를 확인할 수 있습니다.
   - 스크립트 실행 로그는 `<스크립트_이름>.log` 파일에 저장됩니다.

## 주요 구성 요소 설명

1. **ClusterRoleBinding 점검**:
   - `kubectl get clusterrolebindings` 명령어를 사용하여 `cluster-admin` 역할이 할당된 사용자, 그룹, 서비스 계정을 확인합니다.

2. **CSV 출력**:
   - 점검 결과를 `category`, `code`, `riskLevel`, `diagnosisItem`, `service`, `diagnosisResult`, `status` 필드로 구성된 CSV 파일에 저장합니다.

3. **로그 파일**:
   - 스크립트 실행 중 발생한 세부 사항을 `<스크립트_이름>.log` 파일에 기록합니다.

## 예시 출력

### CSV 파일 예시

| category      | code      | riskLevel | diagnosisItem               | service            | diagnosisResult                                                              | status |
|---------------|-----------|-----------|-----------------------------|--------------------|------------------------------------------------------------------------------|--------|
| 기술적 보안    | PRC-C-001 | 5         | 불필요한 클러스터 관리자 역할 부여 | 컨테이너 가상화 시스템 | 사용자, 그룹, 서비스 계정에 불필요한 클러스터 관리자(cluster-admin) 역할이 부여되어 있음 | 취약   |

### 로그 파일 예시

```plaintext
Checking for unnecessary cluster-admin role assignments...
Cluster-Admin Role Assignments: 사용자, 그룹, 서비스 계정에 불필요한 클러스터 관리자(cluster-admin) 역할이 부여되어 있음
```

## 중요 사항

- **권한 관리**:
  - 스크립트 실행자는 클러스터에서 `kubectl` 명령어를 실행할 수 있는 충분한 권한이 있어야 합니다.

- **보안 권고**:
  - `cluster-admin` 역할은 클러스터 전반에 걸친 강력한 권한을 부여하므로 불필요하게 사용되지 않도록 관리해야 합니다.

## 라이선스

이 프로젝트는 MIT 라이선스에 따라 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 작성자

[Your Name](https://github.com/your-profile)이 작성하였습니다.

---

문제나 제안 사항이 있으면 리포지토리에서 이슈나 풀 리퀘스트를 열어주세요.
