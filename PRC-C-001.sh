#!/bin/bash

# Output file for the results
OUTPUT_CSV="output_cluster_admin_roles.csv"
TMP1=$(basename "$0").log

# Define the category and other fields for CSV output
category="기술적 보안"
code="PRC-C-001"
riskLevel="5"
diagnosisItem="불필요한 클러스터 관리자 역할 부여"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Create CSV header if it does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Function to check for unnecessary cluster-admin role assignments
check_cluster_admin_role() {
    echo "Checking for unnecessary cluster-admin role assignments..."

    # Get all clusterrolebindings and check if 'cluster-admin' is assigned
    kubectl get clusterrolebindings -o=custom-columns='NAME:.metadata.name','ROLE:.roleRef.name','KIND:.subjects[*].kind','NAME:.subjects[*].name','NAMESPACE:.subjects[*].namespace' | awk '/cluster-admin/' > $TMP1

    # Check if any 'cluster-admin' roles were found
    if [ -s $TMP1 ]; then
        diagnosisResult="사용자, 그룹, 서비스 계정에 불필요한 클러스터 관리자(cluster-admin) 역할이 부여되어 있음"
        status="취약"
    else
        diagnosisResult="사용자, 그룹, 서비스 계정에 불필요한 클러스터 관리자(cluster-admin) 역할이 부여되어 있지 않음"
        status="양호"
    fi

    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Cluster-Admin Role Assignments: $diagnosisResult" >> $TMP1
}

# Check for unnecessary cluster-admin role assignments
check_cluster_admin_role

# Output the detailed results to the terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
