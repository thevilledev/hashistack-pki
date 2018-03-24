# hashistack-pki

Create your own local environment for trying out auto-generated TLS certificates.
Test environment is run on a Debian Stretch machine on top of VirtualBox. This environment
suitable for testing out Nomad and Vault PKI, but also HTTP/2 and service orchestration
in general.

This environment has the following services built in:

- [Consul](https://www.consul.io/) server for storage backend and service discovery
- [Vault](https://www.vaultproject.io/) server for PKI
- [Nomad](https://www.nomadproject.io/) client & server
- Docker for running Nomad jobs
- [Fabio](https://github.com/fabiolb/fabio) running in a container as a load balancer
- [Sample Go application](https://github.com/vtorhonen/go-vault-pki/tree/master/examples/demo-app) running in a container. [Available on Dockerhub](https://hub.docker.com/r/vtorhonen/vault-pki-demo-app/).

Provisioning is handled by Ansible. Ansible calls Terraform to set up Vault and Consul
configuration, which cannot be configured through config files.

# Project structure

- `provisioning/`: Ansible configuration
    - `group_vars`: Global variables for selecting Vault/Nomad/Terraform/Consul versions
    - `roles`: Ansible roles for each component
- `jobs`: Nomad jobs for running load balancer and app
- `tf`: Terraform configuration


# PKI setup

PKI is initialized as follows:

- Root CA is issued by Terraform.
- Vault PKI is initialized by creating a CSR for a sub-CA.
- Terraform signs the certificate request for sub-CA.
- Vault installs sub-CA certificate to its PKI.

Sub-CA private key is never exported and actually cannot even be exported from Vault.

# How do I use this?

Ensure you have VirtualBox and Vagrant installed. Then run `vagrant up`. During boot up
Ansible will print out Vault unseal keys and root token. Store them somewhere as you
will need them. This is the only time the keys are printed out and after that your
keys are unrecoverable.

Log in to the instance by running `vagrant ssh`. Then run `nomad status` to see which
services are scheduled to the instance.

```
$ nomad status
ID   Type     Priority  Status   Submit Date
app  service  50        running  03/24/18 15:07:36 GMT
lb   service  50        running  03/24/18 15:05:12 GMT
```

After Ansible has finished provisioning you then have the following two Nomad jobs running:

- `app` is a Go sample application which prints "welcome" and gives HTTP 200 as a response. It registers to Consul by service name "testapp".
- `lb`: load balancer which uses healthy Consul services as backend and adds them automatically to its configuration. It also auto-generates TLS certificates and also renews them.

Verify that the setup is working by running the following command:

```
$ curl -vk https://testapp-lb.query.consul
...
* Server certificate:
*  subject: CN=testapp-lb.query.consul
*  start date: Mar 24 15:07:35 2018 GMT
*  expire date: Apr  3 15:08:05 2018 GMT
*  issuer: CN=Sub-CA for HashiStack PKI
...
* Using HTTP2, server supports multi-use
...
< HTTP/2 200
< content-type: text/plain; charset=utf-8
< date: Sat, 24 Mar 2018 15:27:54 GMT
< content-length: 7
<
* Connection #0 to host testapp-lb.query.consul left intact
welcome
```

From this we can see that our load balancer supports HTTP/2 and is serving
content by using TLS certificate with a Common Name (CN) of `testapp-lb.query.consul`.
You can also run the command from the host machine by using correct SNI hostname mapping.

```
$ curl -vk --resolve testapp-lb.query.consul:443:192.168.33.102 https://testapp-lb.query.consul
```

Finally check the load balancer logs:

```
$ nomad status lb | grep ' run '
dc41d70f  38334ef9  fabio       0        run      running  25m29s ago  25m26s ago

$ nomad logs -stderr dc41d70f
...
+ route add testapp testapp-lb.query.consul/ https://192.168.33.102:30819 opts "tlsskipverify=true"
...
2018/03/24 15:08:05 [INFO] cert: vault: issued cert for testapp-lb.query.consul; serial = 59-47-2b-38-c6-c3-88-37-22-f5-06-61-fd-68-9e-f1-5b-94-26-ac
```

Done, you made it. Have a beer.
