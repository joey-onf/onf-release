# -*- python -*-
## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import pprint
import time

from probe.main        import utils           as main_utils
from probe.main        import argparse        as main_getopt
from probe.main        import service_action

from probe.detect      import utils           as probe_detect

from probe.do          import derived         as do_derived
from probe.do          import domain          as do_domain
from probe.do          import email           as do_email
from probe.do          import host            as do_host
from probe.do          import ip              as do_ip
from probe.do          import services        as do_svc
from probe.do          import url             as do_url

from probe.network     import onf_ip
from probe.network     import onf_ping
from probe.network     import onf_protocols
from probe.network     import onf_ssh

# Memcached resource and attribute storage.
from probe.storage     import mem_cache
from probe.storage     import mem_state
from probe.storage     import mem_todo

from probe.struct      import probe_rec       as pr

from probe.streams     import storage

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
seen_resource_cache = {} # global
def looping_resource_active(arg:str) -> bool:
    '''Gatekeeper for looping resource check.
    DEFAULT Single iteration per resource.
       ELSE count set by domain/host lib (ip lookup).

    :param arg: Name of resource for check or skip detection.
    :type  arg: str
    
    :return: Status set by detection
    :rtype: bool
    '''

    active = True
    if arg not in seen_resource_cache:
        seen_resource_cache[arg] = True
    else:
        active = probe_derived.is_probe_active(arg, no_create=True)

    return active

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def filtered_stream() -> str:
    '''Return the next resource to probe.

    1) Iterate over raw list.
    2) --excl(ude) resources mentioned on command line.
    3) Skip resources seen>[n] times
    4) Return value may be a string or data structure.
    '''

    iam   = main_utils.iam()
    
    argv    = main_getopt.get_argv()
    debug   = argv['debug']
    verbose = argv['verbose']

    excl = []
    excl += argv['excl']

    trace = []
    trace += argv['trace']

    # ------------------------
    # 138.68.30.104 => onfweb1
    # ------------------------
    tt = mem_todo.Util()
    while tt.todo_has():
        val = tt.todo_shift()

        yield_arg = val
        action_rec = None

        ## ----------------------------------------------
        ## Records added by probe/network/* library calls
        ## ----------------------------------------------
        if isinstance(val, dict):

            ## --------------------------------------
            ## Add module to define class
            ## constructor packages attributes
            ## Simplifies this call into isinstance()
            ## --------------------------------------
            if 'resource' in val:  

                arg = val['resource']
                if onf_ip.Utils().is_local_network(arg):
                    prec = pr.ProbeRec(resource)\
                             .add_to({'iam':main_utils.iam(), 'private-ip':True})
                    
                    ## Skip localhost and private IPs, all services hang.
                    if verbose:
                        print(" ** %s [SKIP] is_local_network(%s)" % (iam, arg))
                    continue

                action_rec = val
                ## Generate a per-service key to enable checking (elif seen_{ip}_skip)
                val = '__'.join([ val[key] for key in ['resource', 'action']])
            else:
                for key in ['by_host', 'by_ip']:
                    if key in val:
                        val = val[key]
                        break

        domain = val # rename domain to resource
        domain_lower = domain.lower()

        if len(excl) > 0 and domain_lower in excl:
            # prec = pr.ProbeRec(domain_lower).add_to({'skip':True})
            continue

        ## ------------------------------------------------
        ## Seen already or Host pool iteration (max>seen++)
        ## ------------------------------------------------
        if not looping_resource_active(domain_lower):
            continue

        ## ----------------------------------------------
        ## Maintain a list for spreadsheet iteration loop
        ## ----------------------------------------------
        mc_obj  = mem_cache.Utils('localhost')
        cache = None
        value = domain_lower
        
        if mc_obj.has(value):
            cache = mc_obj.get('__cache_index__')
        if cache is None: # why did has() + get() return None ?
            cache = []
        if value not in cache:
            mc_obj.put('__cache_index__', [value])

        ## ----------------------------------------------
        ## Create initial meta record for gathering state
        ## ----------------------------------------------
        rec=\
            {
                'iam'      : iam,
                'created'  : str(time.time()),
                'resource' : domain,
            }
        prec = pr.ProbeRec(domain_lower).add_to(rec)

        yield_arg = action_rec \
            if action_rec is not None \
            else val

        yield yield_arg

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def gather():
    """Perform actions based on command line args.

    :param argv: Command line args processed by python getopts
    :type  argv: dict

    :return: Success/failure set by action performed
    :rtype : bool
    """

    argv  = main_getopt.get_argv()
    debug = argv['debug']
    trace = argv['trace']

    for value in filtered_stream():

        if debug:
            msg = '\n' + pprint.pformat(value, indent=4) \
                if isinstance(value, dict) \
                else value
            print('''
** -----------------------------------------------------------------------
** GATHER: %s
** -----------------------------------------------------------------------
''' % msg)

        if argv['trace_all'] or value in trace:
            import pdb
            pdb.set_trace()
            begin_trace = value

        detected = probe_detect.By(value).detect_type()

        if not detected.is_valid():
            raise Exception("%s: probe_detect failed for %s" % (iam, value))

        elif detected.is_action():
            action = detected.get_action()
            # [TODO] detected.invoke(value) # callback / dispatcher
            service_action.service_action(value)
            value = detected.get_resource()
            
        # elif detected.is_raw():
            # detected.invoke(value) # callback / dispatcher
        
        # elif url_utils.Utils().is_valid(value):
        elif detected.is_raw('url'):
            do_url.Url().request(value, trace=False)

        # elif onf_email.Utils().is_valid(value):
        elif detected.is_raw('email'):
            # onf_email.Utils(value).email_probe()
            do_email.Email(trace=False).request(value)

        # elif onf_cidr.Utils().is_cidr(value):
        elif detected.is_raw('cidr'):
            onf_cidr.Utils().probe(value)
            
        ## --------------------------------------
        #elif onf_ip.Utils().is_ip_address(value):
        elif detected.is_raw('address'):
            do_ip.Ip(trace=False).request(value)

        # elif onf_network.Utils().is_ip_network(value):
        elif detected.is_raw('network'):
            onf_network.Utils().probe(value, trace=False)

        # just in case
        elif onf_ip.Utils().is_ip_syntax(value):
            msg = pprint.pformat({
                'iam'   : main_utils.iam(),
                'error' : 'HUH(?) xx.xx.xx.xx not detected as an IP or network',
                'arg'   : arg,
            }, indent=4)
            raise ValueError(msg)

        ## --------------------------------------
        # elif onf_domain.Utils().is_valid(value): 
        elif detected.is_raw('domain'):
            # do_domain.Domain().request(value)
            domain_utils.Do().probe(value, trace=False)

        # elif onf_hostname.Utils().is_valid(value):
        elif detected.is_raw('hostname'):
            if True:
                do_host.Host(debug=False, trace=True).request(resource)
            else:
                do_hostname_orig(value, debug=True, trace=False)

        else:
            raise Exception('Detected unhandled type: %s' % value)

        ## ------------------------------------------------
        ## TODO: Loop for several minutes to read host pool
        ## ------------------------------------------------
        # prec = pr.ProbeRec(value)

        # -----------------------------------------------------
        # socket.gaierror: [Errno -2] Name or service not known
        # make: *** [makefile:28: try] Error 1
        # -----------------------------------------------------
        
        rec = mem_cache.Utils('localhost').get(value)
        pprint.pprint({
            '__ARG__' : value,
            'rec' : rec,
        }, indent=4)

        ## write to disk
        store = storage.Utils(value).write('meta', rec, magic='json')
