set -e
set -o pipefail
set -x

# If you want to build image manually:
# 1. uncomment build in docker-compose.yml
# 2. run python update_queues_names.py xqueue/settings.py test.json
# 3. run docker-compose build xqueue
# 4. run this script
# Otherwise, run this script

# Bring up XQueue
docker-compose up -d xqueue
# Run migrations
docker-compose exec xqueue bash -c "cd /edx/app/xqueue && python manage.py migrate"
# Add users from file 
docker-compose exec xqueue bash -c "cd /edx/app/xqueue && python manage.py update_users_from_file --file $1"
