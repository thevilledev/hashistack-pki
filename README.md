# hashistack-pki

Create your own local environment for trying out auto-generated TLS certificates.
Test environment is run on a Debian Stretch machine on top of VirtualBox. It's
suitable for testing out Nomad and Vault PKI, but also HTTP/2 and service orchestration
in general.

This environment has the following services built in:

- Consul server for storage backend and service discovery
- Vault server for PKI
- Nomad client & server
- Docker for running Nomad jobs
- Fabio running in a container as a load balancer
- Sample Go application running in a container

Provisioning is handled by Ansible. Ansible calls Terraform to set up Vault PKI and Terraform
uses Consul as a storage backend.

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

- `app` is a Go sample application which prints "welcome". It registers to Consul by service name "testapp".
- `lb`: load balancer which uses healthy Consul services as backend and adds them automatically to its configuration. It also auto-generates TLS certificates and also renews them.

You can verify that the setup is working by running the following command:

```
$ curl -k --resolve testapp-lb.query.consul:443:192.168.33.102 https://testapp-lb.query.consul
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
Finally check the load balancers logs:

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
