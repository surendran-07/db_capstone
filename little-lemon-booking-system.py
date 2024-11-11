# Import MySQL Connector/Python
import mysql.connector as connector
from mysql.connector import errorcode


# Establish connection
def create_connection():
    try:
        connection = connector.connect(user="root", password="yasminrandom", database="little_lemon_db")
        return connection  # Return the connection object

    except connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Connection user or password are incorrect")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)
        return None

def call_procedure(procedure_name, *args):
    connection = create_connection()
    if connection is None:
        return
    
    try:
        cursor = connection.cursor()
        cursor.callproc(procedure_name, args)

        for result in cursor.stored_results():
            print(result.fetchall())
    except connector.errors as err:
        print(f"Error executing {procedure_name}: {err}")
        return None

    finally:
        cursor.close()
        connection.close()


def get_max_quantity():
    result = call_procedure('GetMaxQuantity')
    if result:
        print(result[0])  # Print the first result row

def manage_booking(booking_date, table_number):
    results = call_procedure('ManageBooking', booking_date, table_number)
    if results:
        print(results)

def update_booking(booking_id, booking_date):
    results = call_procedure('UpdateBooking', booking_id, booking_date)
    if results:
        print(results)

def add_booking(booking_id, customer_id, booking_date, table_number):
    results = call_procedure('AddBooking', booking_id, customer_id, booking_date, table_number)
    if results:
        print(results)

def cancel_booking(booking_id):
    results = call_procedure('CancelBooking', booking_id)
    if results:
        print(results)

def show_all_tables():
    connection = create_connection()
    if connection is None:
        return
    
    try:
        cursor = connection.cursor()
        show_table_query = """SHOW tables"""
        cursor.execute(show_table_query)

        tables = cursor.fetchall()

        for table in tables:
            print(table[0])

    except connector.errors as err:
        print("Error querying tables: ", err)
        return None

    finally:
        cursor.close()
        connection.close()

def show_customer_order_above60():
    connection = create_connection()
    if connection is None:
        return
    
    try:
        cursor = connection.cursor()
        show_customer_query = """SELECT DISTINCT FullName, ContactNumber, Email 
        FROM Customers
        JOIN Orders ON Customers.CustomerID = Orders.CustomerID
        WHERE Orders.TotalCost > 60"""
        cursor.execute(show_customer_query)

        customers = cursor.fetchall()

        for customer in customers:
            print(customer)

    except connector.errors as err:
        print("Error fetching details: ",err)
    
    finally:
        cursor.close()
        connection.close()


# Create the connection
connection = create_connection()

# If the connection was successful, add a booking
if connection:
    get_max_quantity()
    manage_booking("2022-10-11",5)
    update_booking(12,"2022-10-16")
    add_booking(13, 10, "2022-10-31", 5)
    cancel_booking(12)
    show_all_tables()
    show_customer_order_above60()