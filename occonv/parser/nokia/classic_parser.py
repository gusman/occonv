import logging

from ttp_sros_parser.srosparser import SrosParser


class ClassicParser:
    def __init__(self, cfg_path: str):
        try:
            self.parser = SrosParser(cfg_path)
        except (ValueError, SystemExit) as e:
            self.parser = None
            logging.error(e)

    def get_full_config(self):
        ret = {}

        if isinstance(self.parser, SrosParser):
            ret = self.parser.get_full_config(json_format=False)

        return ret
