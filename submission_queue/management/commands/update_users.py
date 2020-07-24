"""
Ensure that the right users exist:

- read USERS dictionary from settings
- if they don't exist, create them.
- if they do, update the passwords to match

"""
import logging

from django.conf import settings
from django.core.management.base import BaseCommand

from .utils import create_or_update_users

log = logging.getLogger(__name__)


class Command(BaseCommand):
    help = "Create users that are specified in your configuration"

    def handle(self, *args, **options):
        create_or_update_users(settings.USERS)
