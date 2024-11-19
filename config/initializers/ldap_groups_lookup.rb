LDAPGroupsLookup.config = {
  enabled: ESSI.config[:ldap][:enabled],
  config: { host: ESSI.config[:ldap][:host],
            port: ESSI.config[:ldap][:port] || 636,
            encryption: {
              method: :simple_tls,
              tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS,
            },
            auth: {
              method: :simple,
              username: "cn=#{ESSI.config[:ldap][:user]}",
              password: ESSI.config[:ldap][:pass],
            }
  },
  tree: ESSI.config[:ldap][:tree],
  account_ou: ESSI.config[:ldap][:account_ou],
  group_ou: ESSI.config[:ldap][:group_ou]
}