import argparse
import json
import sys
import re


def replace_dct_source(source, dct_name, new_dct_source):
    """Finds dct_name entry and replaces it with new source
    if dct_name entry is not found, then places new source at the end
    """
    regex = re.compile("(" + dct_name + "\s*=\s*{(.*\n?)*})", re.MULTILINE)
    result = regex.search(source)
    if result is not None:
        entry_start, entry_end = result.span()
        source = source[:entry_start] + new_dct_source + source[entry_end:]
    else:
        source += '\n' + new_dct_source

    return source


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('module_name', help='Module name to insert data into')
    parser.add_argument('json_name', help='Json with new xqueue names')
    args = parser.parse_args()

    with open(args.json_name, 'r') as f:
        json_content = json.load(f)
        queues_names_dct = json_content.get('queue_names')
        if queues_names_dct is None:
            queues_names_dct = {}
        new_xqueues = 'XQUEUES = {}'.format(json.dumps(queues_names_dct, sort_keys=True, indent=4))

    with open(args.module_name, 'r+') as f:
        source = f.read()
        new_source = replace_dct_source(source, 'XQUEUES', new_xqueues)
        f.seek(0)
        f.write(new_source)

