set -e
set -o pipefail
set -x

# Bring the databases online.
docker-compose up -d mysql

# Ensure the MySQL server is online and usable
echo "${GREEN}Waiting for MySQL.${NC}"
until docker-compose exec -T mysql bash -c "mysql -uroot -se \"SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'root')\"" &> /dev/null
do
  printf "."
  sleep 1
done

# In the event of a fresh MySQL container, wait a few seconds for the server to restart
# See https://github.com/docker-library/mysql/issues/245 for why this is necessary.
sleep 20
echo -e "${GREEN}MySQL ready.${NC}"

# Ensure that the MySQL databases and users are created for all IDAs.
# (A no-op for databases and users that already exist).
echo -e "${GREEN}Ensuring MySQL databases and users exist...${NC}"
docker-compose exec -T mysql bash -c "mysql -uroot mysql" < provision.sql

# Set queue names in Xqueue settings.py
#python update_queues_names.py xqueue/settings.py queue_names.json
# Bring up XQueue
docker-compose up -d --build xqueue
# Run migrations
docker-compose exec xqueue bash -c 'cd /edx/app/xqueue && python manage.py migrate'
# Add users that graders use to fetch data, there's one default user in Ansible which is part of our settings
docker-compose exec xqueue bash -c 'cd /edx/app/xqueue && python manage.py update_users' 
# Replace previous command with this when json file ready
#docker-compose exec xqueue bash -c 'cd /edx/app/xqueue && python manage.py update_users_from_file -f users.json' 
