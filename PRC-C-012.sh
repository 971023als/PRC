	PRC-C-012	기술적 보안	"컨테이너
가상화
시스템"	2. 시스템 서비스 관리	4. API	API 통신에 대한 보안 프로토콜 사용	3	API 통신 구간의 암호화가 적용되지 않을 경우, API 요청 내용이 위변조 될 수 있으므로, API 통신에 대한 보안 프로토콜(TLS) 적용 여부를 점검	ㅇ	ㅇ	ㅇ	"* API 프로세스 또는 설정파일을 통해 ""tls-cert-file"" 및 ""tls-private-key-file"" 설정을 확인

  - (방법1) $ ps -ef | grep apiserver | grep -E tls-cert-file|tls-private-key-file | grep -v grep 
  - (방법2) $ grep -E ""tls-cert-file|tls-private-key-file"" ""/etc/kubernetes/manifests/kube-apiserver.yaml""
  - (방법3) $ kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath=""{range .items[]}{.spec.containers[].command}{''}{end}"" | grep -E ""tls-cert-file|tls-private-key-file"" "	"* 양호 - 'tls-cert-file', 'tls-private-key-file'가 설정되어 있을 경우
* 취약 - 'tls-cert-file', 'tls-private-key-file'가 미설정 되어 있을 경우"	"* kubelet 프로세스 또는 설정파일을 통해 ""tls-cert-file"" 및 ""tls-private-key-file"" 설정을 확인

  - (방법1) $ ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern=""tls-cert-file tls-private-key-file""
  - (방법2) $ grep -q ""tls-cert-file tls-private-key-file"" ""/var/lib/kubelet/config.yaml""
  - (방법3) $ grep -q ""tls-cert-file tls-private-key-file"" ""/etc/systemd/system/kubelet.service.d/10-kubeadm.conf""
  - (방법4) $ grep -q ""tls-cert-file tls-private-key-file"" ""/lib/systemd/system/kubelet.service""
  - (방법5) $ grep -q ""tls-cert-file tls-private-key-file"" ""/var/lib/kubelet/config.yaml"""	"* 양호 - tls-cert-file, tls-private-key-file 플래그가 설정되어 있을 경우
* 취약 - tls-cert-file, tls-private-key-filee 플래그가 미설정 되어 있을 경우"	"* API 통신에 보안 프로토콜 적용을 위한, 인증서 설정 여부를 확인

* (방법1) Docker 데몬 명령줄에 'tlsverify|tlscacert|tlscert|tlskey' 인자값 확인
> $ ps -ef | grep 'dockerd' | grep -e ""tlsverify|tlscacert|tlscert|tlskey"" | grep -v grep
>>
* (방법2)  docker 설정파일(/etc/docker/daemon.json)을 열어 'tlsverify|tlscacert|tlscert|tlskey' 값 확인
> $ sudo cat /etc/docker/daemon.json | grep -e ""tlsverify|tlscacert|tlscert|tlskey""
>> ""tlsverify"": true,
>> ""tlscacert"": ""/path/to/ca.pem"",
>> ""tlscert"": ""/path/to/cert.pem"",
>> ""tlskey"": ""/path/to/key.pem""
* (방법3) 아래 명령어 실행 후, '.TLSConfig.InsecureSkipVerify' 값 확인
> $ docker info --format 'TLS Enabled: {{.TLSConfig.InsecureSkipVerify}}'
>> TLS Enabled: false"	"* 양호: Rest API를 사용하지 않거나, 보안 프로토콜 사용을 위한 인증서 설정을 하고 있을 경우
* 취약: API 통신에 보안 프로토콜 사용을 위한 인증서 설정을 하지 않은 경우

※ Docker가 API 기능을 사용하지 않을 경우, 대상에서 제외"													
