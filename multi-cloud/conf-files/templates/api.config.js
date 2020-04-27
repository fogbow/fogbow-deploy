export const env = {
	as: 'https://atm-test-site2.lsd.ufcg.edu.br/as',
	ras: 'https://atm-test-site2.lsd.ufcg.edu.br/ras',
	fns: 'https://atm-test-site2.lsd.ufcg.edu.br/ras',
	ms: 'https://atm-test-site2.lsd.ufcg.edu.br/ms',
	local: 'atm-test-site2.lsd.ufcg.edu.br',
    serverEndpoint: '',
	deployType: 'fns-deploy',
    refreshTime: 5000,
    remoteCredentialsUrl: '',
    authenticationPlugin: 'LDAP',
    credentialFields: {
        username: {
            type: 'text',
            label: 'User Name'
        },
        password: {
            type: 'password',
            label: 'Password'
        }
    },
	fnsServiceNames: ['vanilla'],
};