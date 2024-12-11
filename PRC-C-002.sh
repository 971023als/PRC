#!/bin/bash

# Output file for the results
OUTPUT_CSV="output_role_permissions.csv"
TMP1=$(basename "$0").log

# Define the category and other fields for CSV output
category="기술적 보안"
code="PRC-C-002"
riskLevel="4"
diagnosisItem="Role(ClusterRole)의 과도한 권한 부여"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Create CSV header if it does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Function to check for wildcard permissions in roles and cluster roles
check_wildcard_permissions() {
    echo "Checking for wildcard (*) permissions in Roles and ClusterRoles..."

    # Get all roles and cluster roles and check if they contain wildcard (*)
    kubectl get roles --all-namespaces -o=jsonpath='{range .items[*]}{"Role: "}{.metadata.name}{" - Namespace: "}{.metadata.namespace}{""}{range .rules[*]}{"Verbs: "}{.verbs}{" APIGroups: "}{.apiGroups}{" Resources: "}{.resources}{"\n"}{end}{end}' > $TMP1

    # Search for wildcard (*) in verbs, API groups, or resources
    wildcard_permissions=$(grep -E "Verbs: \*|APIGroups: \*|Resources: \*" $TMP1)

    if [ -n "$wildcard_permissions" ]; then
        diagnosisResult="Role 또는 ClusterRole에 와일드 카드(*)가 부여되어 있음"
        status="취약"
    else
        diagnosisResult="Role 및 ClusterRole에 와일드 카드(*)가 부여되어 있지 않음"
        status="양호"
    fi

    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Wildcard Permissions in Roles or ClusterRoles: $diagnosisResult" >> $TMP1
}

# Check for wildcard permissions in roles and cluster roles
check_wildcard_permissions

# Output the detailed results to the terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
