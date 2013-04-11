from fabric.api import run
from fabric.api import env


env.roledefs = {
        "app": [
            ]
        }

def backup_db_config():
    run('cp /home/www/v2/image/config/database.php /home/www/v2/image/config/database.php.backup')

def sync_config():
    run('scp evans@img02-008:/tmp/database.php /home/www/v2/image/config/database.php', shell=True)

def rollback():
    run('cp /home/www/v2/image/config/database.php.backup /home/www/v2/image/config/database.php')

def backup_dfs_config():
    run('cp /home/www/v2/image/config/dfs.php /home/www/v2/image/config/dfs.php.backup')


def sync_dfs_config():
    run('scp evans@app10-045:/tmp/dfs.php /home/www/v2/image/config/dfs.php')

def roll_dfs_config():
    run('cp /home/www/v2/image/config/dfs.php.backup /home/www/v2/image/config/dfs.php')




def backup_dfs_new_config():
    run('cp /home/www/v2/image/config/dfs-new.php /home/www/v2/image/config/dfs-new.php.backup')



def sync_dfs_new_config():
    run('scp evans@app10-045:/tmp/dfs-new.php /home/www/v2/image/config/dfs-new.php')

def roll_dfs_new_config():
    run('cp /home/www/v2/image/config/dfs-new.php.backup /home/www/v2/image/config/dfs-new.php')
