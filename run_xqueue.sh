set -e
set -o pipefail
set -x

# Set queue names in Xqueue settings.py, AVAILABLE ONLY IN BUILD USING DOCKERFILE, with --build option
#python update_queues_names.py xqueue/settings.py $1
# Bring up XQueue
docker-compose up -d xqueue
# Run migrations
docker-compose exec xqueue bash -c "cd /edx/app/xqueue && python manage.py migrate"
# Add users from file 
docker-compose exec xqueue bash -c "cd /edx/app/xqueue && python manage.py update_users_from_file --file $1"
