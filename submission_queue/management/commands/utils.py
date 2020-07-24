import logging

from django.contrib.auth.models import User


log = logging.getLogger(__name__)


def create_or_update_users(users):
    if users is None:
        log.error('Users dictionary is not set')
        return

    for username, pwd in users.items():
        log.info(' [*] Creating/updating user {0}'.format(username))
        try:
            user = User.objects.get(username=username)
            user.set_password(pwd)
            user.save()
        except User.DoesNotExist:
            log.info('     ... {0} does not exist. Creating'.format(username))

            user = User.objects.create(username=username,
                                       email=username + '@dummy.edx.org',
                                       is_active=True)
            user.set_password(pwd)
            user.save()
