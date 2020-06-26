## Configuring a CAFe Service Provider to use as the underlying authentication service of a Fogbow node

RNP provides [documentation](https://wiki.rnp.br/pages/viewpage.action?pageId=69969868) on how to become a Service Provider of the CAFe Identity Provider 
federation. Reading this documentation is not required, but is advisable.

To become a Service Provider you need to follow these steps:

1. Create a certificate.

1.1. Create a file */tmp/openssl.cnf* with the content below and replace the values of the fields with the 
appropriate values.
```bash
[ req ]
default_bits = 2048 # Size of keys
string_mask = nombstr # permitted characters
distinguished_name = req_distinguished_name
 
[ req_distinguished_name ]
# Variable name   Prompt string
#----------------------   ----------------------------------
0.organizationName = Nome da universidade/organização
organizationalUnitName = Departamento da universidade/organização
emailAddress = Endereço de email da administração
emailAddress_max = 40
localityName = Nome do município (por extenso)
stateOrProvinceName = Unidade da Federação (por extenso)
countryName = Nome do país (código de 2 letras)
countryName_min = 2
countryName_max = 2
commonName = Nome completo do host (incluíndo o domínio)
commonName_max = 64
 
# Default values for the above, for consistency and less typing.
# Variable name   Value
#------------------------------   ------------------------------
#0.organizationName_default =
organizationalUnitName_default = CPD
#localityName_default = Porto Alegre
#stateOrProvinceName_default = Rio Grande do Sul
countryName_default = BR
commonName_default = $HOSTNAME
```

***$HOSTNAME*** is the DNS name of the server where the Service Provider will run.

1.2. Create certificates and key
```bash
openssl genrsa -out /etc/ssl/private/$HOSTNAME.key 2048 -config /tmp/openssl.cnf
openssl req -new -key /etc/ssl/private/$HOSTNAME.key -out /etc/ssl/private/$HOSTNAME.csr -batch -config /tmp/openssl.cnf
openssl x509 -req -days 730 -in /etc/ssl/private/$HOSTNAME.csr -signkey /etc/ssl/private/$HOSTNAME.key -out /etc/ssl/certs/$HOSTNAME.crt
```

1.3. Create a file */tmp/$HOSTNAME-metadata-sp.xml* with the content below and replace the values as necessary.
```bash
<EntityDescriptor entityID="https://$HOSTNAME/shibboleth-sp2">
    <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:1.1:protocol urn:oasis:names:tc:SAML:2.0:protocol">
      <KeyDescriptor>
        <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
          <ds:X509Data>
            <ds:X509Certificate>
$CERTIFICATE
            </ds:X509Certificate>
          </ds:X509Data>
        </ds:KeyInfo>
      </KeyDescriptor>
      <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://$HOSTNAME/Shibboleth.sso/SAML2/POST" index="1"/>
      <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign" Location="https://$HOSTNAME/Shibboleth.sso/SAML2/POST-SimpleSign" index="2"/>
      <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact" Location="https://$HOSTNAME/Shibboleth.sso/SAML2/Artifact" index="3"/>
      <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:PAOS" Location="https://$HOSTNAME/Shibboleth.sso/SAML2/ECP" index="4"/>
      <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post" Location="https://$HOSTNAME/Shibboleth.sso/SAML/POST" index="5"/>
      <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:artifact-01" Location="https://$HOSTNAME/Shibboleth.sso/SAML/Artifact" index="6"/>
    </SPSSODescriptor>
    <Organization>
      <OrganizationName xml:lang="en">$INITIALS - $ORGANIZATION_DESCRIPTION</OrganizationName>
      <OrganizationDisplayName xml:lang="en">$INITIALS - $ORGANIZATION_DESCRIPTION</OrganizationDisplayName>
      <OrganizationURL xml:lang="en">http://$ORGANIZATION_DOMAIN</OrganizationURL>
    </Organization>
   <ContactPerson contactType="technical">
    <SurName>TI</SurName>
    <EmailAddress>email@dominio</EmailAddress>
   </ContactPerson>
</EntityDescriptor>
```

Values to replace in the file */tmp/$HOSTNAME-metadata-sp.xml* are: 
- ***CERTIFICATE*** is the content of the certificate generated in the previous step; it has been stored in the
file */etc/ssl/certs/$HOSTNAME.crt*.
- ***$HOSTNAME*** is the DNS name of the server where the Service Provider will run.
- ***INITIALS*** is the University/Organization initials. Ex.: UFCG
- ***ORGANIZATION_DESCRIPTION*** is a description for the University/Organization 
- ***ORGANIZATION_DOMAIN*** is the University/Organization domain. Ex.: ufcg.edu.br

1.4. Send the content of the */tmp/$HOSTNAME-metadata-sp.xml* file to RNP and wait for the confirmation that
your service has been registered as a Service Provider.

## Information about CAFe
- Discovery Service: https://ds.chimarrao.cafe.rnp.br/WAYF
- Discovery Service Metadata: https://ds.chimarrao.cafe.rnp.br/metadata/chimarrao-metadata.xml

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)