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

from probe.main        import gather          as main_gather
from probe.do          import services        as do_svc
from probe.storage     import mem_cache

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def gather():
    '''Call library methods to collect report data.'''

    iam = main_utils.iam()
    main_gather.gather()

    return

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def skip_non_resource(arg:str):
    '''Skip cached derived attributed records.

    :param arg: Agument to check.
    :type  arg: str

    :return: Status set based on detection.
    :rtype:  bool

    .. note: Skip records used to capture atomic attributes that are
    .. note: used to fully define a domain/host/ip network resource.
    '''
    
    excls=\
        [
            '__do_',
            'do_http',
            'do_https',  # '138.68.30.104__do_https'
            'do_ping',
            'do_ssh',
         ]

    ans = False
    for excl in excls:
        if excl in arg:
            ans = True
            break
    
    return ans

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def get_prepare_default():
    rec=\
        {
            'hostname'  : None,
            'hostnames' : [],
            #
            'ip'        : None,
            'ips'       : [],
        }

    services = do_svc.Svcs().get_services_list()
    prefixes = ['can']
    prefixes += ['is']

    for service in services:
        rec[service] : {'ok':None}
        for prefix in prefixes:
            key = '%s_%s' % (service, prefix)
            rec[key] = None
    
    return rec

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def prepare():
    '''Aggregate gathered information for reporting.''' 

    iam = main_utils.iam()
    debug = False

    import pdb
    pdb.set_trace()
    
    ## -----------------------------------------------------------------------
    ## Massage data for reporting
    ## -----------------------------------------------------------------------
    # spread.gen_spreadsheet(data, job_data)
    mem_c = mem_cache.Utils('localhost')
    cache = mem_c.get('__cache_index__')

    services    = do_svc.Svcs().get_services_list()
    do_services = ['__do_%s' % service for service in services]

    wanted=\
        [
            'is_ssh',
            'ping',
            'http', 'https',
            'all_fqdns',
            'all_ip_addresses',
        ]

    aggregate = {}
    for value in cache:

        ## ------------------------------------
        ## Only consider domain/host/ip records
        ## ------------------------------------
        if skip_non_resource(value):
            print("%s [SKIP] %s" % (iam, value))
            continue # '138.68.30.104__do_https'

        ## -----------------------
        ## Get aggregate else init
        ## -----------------------
        agg_rec = aggregate[value]     \
            if value in aggregate      \
            else get_prepare_default()

        ## -------------------------
        ## Merge in gathered content
        ## -------------------------
        rec = mem_c.get(value)
        debug = True
        if debug:
            pprint.pprint({'index':value, 'data':rec})

        services = do_svc.Svcs().get_services_list()
        for service in services:

            key = '%s_can' % service
            if key in agg_rec and agg_rec[key] is not None:
                continue

            if key in rec:                      # http_can, https_can, ping_can
                agg_rec[key] = rec[key]
            else:
                print(" ** KEY: %s" % key)
                not_handled = True

    return aggregate

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def output(path:str):
    '''.'''

    iam = main_utils.iam()

    if False:
        NotImplementedError('%s: --spread-out not yet supported' % (iam))

    return


## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def process():
    '''.'''

    argv  = main_getopt.get_argv()
    
    gather()
    data = prepare()
    pprint.pprint(data)
    if argv['spread_out']:
        output(argv['spread_out'])

    return

# EOF
