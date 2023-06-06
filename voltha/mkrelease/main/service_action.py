# -*- python -*-
## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import pprint

from probe.main        import utils           as main_utils
from probe.main        import argparse        as main_getopt

from probe.detect      import utils           as probe_detect

from probe.do          import derived         as do_derived
from probe.do          import domain          as do_domain
from probe.do          import email           as do_email
from probe.do          import host            as do_host
from probe.do          import ip              as do_ip
from probe.do          import services        as do_svc
from probe.do          import url             as do_url

from probe.network     import onf_ping
from probe.network     import onf_protocols
from probe.network     import onf_ssh


## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def service_action(arg:any) -> bool:
    '''Perform secondary prob operation.

    1) Identify resource and perform primary probe: do_domain, do_host, do_ip
    2) perform secondary service actions: ping, ssh_check
    '''

    argv    = main_getopt.get_argv()
    debug   = argv['debug']
    trace   = argv['trace']
    verbose = argv['verbose']

    detected = probe_detect.By(arg).detect_type()
    if not detected.is_action():
        return False

    ans      = True
    action   = detected.get_action()
    resource = detected.get_resource()

    if action is None:
        raise ValueError("%s: Detected invalid probe action [%s]" % acction)

    elif resource is None:
        raise ValueError("%s: Detected invalid resource [%s]" % resource)

    elif action == 'do_certs':
        raise NotImplementedError("ACTION: %s" % action) # placeholder

    elif action == 'do_derived':
        do_derived.Domain().request(resource, trace=False)
        do_derived.Host().request(resource,   trace=False)

    elif action == 'do_domain':
        do_domain.Domain().request(resource)

    elif action == 'do_ip':
        do_ip.Ip().request(resource)

    elif action == 'do_http':
        onf_protocols.Http().probe(resource, https=False)

    elif action == 'do_https':
        onf_protocols.Http().probe(resource, https=True)

    elif action == 'do_ping':
        onf_ping.Utils().probe(resource)

    elif action == 'do_services':
        do_svc.Svcs().request(resource)

    elif action == 'do_ssh':
        onf_ssh.Utils().probe(resource)         

        # pypi library method has issues
        # paramiko is finicky (auth hosts?)
        # ssh_detect.Remote().probe(resource)

    elif action == 'do_url':
        do_url.Url().request(resource, trace=False)
        
    else:
        iam = main_utils.iam()
        raise ValueError("%s: Detected invalid action %s" % (iam, action))

    return ans
