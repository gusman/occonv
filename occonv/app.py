from occonv.oc import netinst
from occonv.parser.nokia import classic_parser


def run():
    ni = netinst.create_network_instance("test")
    print(ni, type(ni), dir(ni))
    print(ni.dumps())
    print(netinst.dumps())

    nokia_classic_parser = classic_parser.ClassicParser(
        "./test/nokia-classic/P1.cfg"
    )
    print(nokia_classic_parser.get_full_config())
