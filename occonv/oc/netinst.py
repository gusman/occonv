from occonv.oc.bind.openconfig_network_instance import openconfig_network_instance
from pyangbind.lib import pybindJSON

ocni = openconfig_network_instance()
net_instances = {}


class NetworkInstance:
    def __init__(self, oc_netinst):
        self.ni = oc_netinst

    def add_interface(identifier: str, ipv4: str, ipv6: str):
        pass

    def dumps(self):
        return pybindJSON.dumps(self.ni, indent=2)


def create_network_instance(name: str = "base") -> NetworkInstance:
    if name not in net_instances:
        ocni.network_instances.network_instance.add(name)
        net_instances[name] = NetworkInstance(
            ocni.network_instances.network_instance[name]
        )

    return net_instances[name]


def list_network_instance_name():
    return net_instances


def dumps():
    return pybindJSON.dumps(ocni, indent=2)
