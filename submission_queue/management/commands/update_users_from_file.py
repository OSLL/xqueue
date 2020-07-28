"""
Ensure that the right users exist:

- read given json file with users
- if they don't exist, create them.
- if they do, update the passwords to match

"""
import json
import logging
import os

from django.core.management.base import BaseCommand

from .utils import create_or_update_users

log = logging.getLogger(__name__)


class Command(BaseCommand):
    help = "Create users that are specified in given json file"

    def add_arguments(self, parser):
        parser.add_argument('--file', required=True, type=str, help='Path to json file with users')

    def handle(self, *args, **options):
        filename = options.get('file')
        if not os.path.exists(filename):
            log.error('File {} does not exists'.format(filename))
            return

        with open(filename, 'r') as f:
            try:
                json_content = json.load(f)
            except json.JSONDecodeError:
                log.error('Unable to read json data from file {}'.format(filename))
                return
            except Exception:
                log.error('Some error during reading {}'.format(filename))
                return

        create_or_update_users(json_content.get('xqueue_users'))
