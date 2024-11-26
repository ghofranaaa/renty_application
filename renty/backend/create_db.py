import mysql.connector


my_db_connection = mysql.connector.connect(
	host="localhost",
	user="root",
	password="Ghof_rane.04"
)
my_cursor = my_db_connection.cursor()

my_cursor.execute("CREATE DATABASE IF NOT EXISTS db")
my_cursor.execute("USE db")  # Ensure you're using the right database

for database in my_cursor:
    print(database[0].decode())

my_cursor.close()
my_db_connection.close()
