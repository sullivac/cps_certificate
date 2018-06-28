node.default['cps_certificate'].tap do |cps_certificate|
  cps_certificate['thumbprint'] = 'D0BA3562DE80E9CD6F33FBC0BF808CD7F9A8EDD1'
  cps_certificate['password']   = 'my-cert-is-great'
  cps_certificate['store_path'] = 'Cert:\LocalMachine\My'
end
