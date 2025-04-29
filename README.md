# local-host.cloud

This repository holds all information about the local-host.cloud project.

This project is a simple and easy to use local development environment for web applications.

<details>
<summary>Informations for certificate generation</summary>

The following information is just a note for myself and maybe future contributors.

```bash
# Run as root:
certbot certonly --manual --preferred-challenges dns -d "local-host.cloud"
cp /etc/letsencrypt/live/local-host.cloud/*.pem .
exit

# As normal user:
rm certs.zip
openssl x509 -enddate -noout -in cert.pem | sed 's/^notAfter=//; s/ GMT$//' | xargs -I{} date -d "{}" +%s | tr -d '\n' | tee expiry
zip certs.zip *.pem
cd ..
```

</details>
