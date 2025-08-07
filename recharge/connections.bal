import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

// Connection pool configuration for localhost
final sql:ConnectionPool localHostConnectionPool = sql:getGlobalConnectionPool();

// MySQL client with connection pool for localhost
final mysql:Client mysqlClient = check new (
    host = "localhost", 
    user = "root", 
    password = "2431", 
    database = "ballerina", 
    port = 3306,
    connectionPool = localHostConnectionPool
);

// Connection factory function for localhost MySQL connections
public function createLocalHostConnection(string database) returns mysql:Client|error {
    sql:ConnectionPool connectionPool = sql:getGlobalConnectionPool();
    
    mysql:Client newClient = check new (
        host = "localhost",
        user = "root", 
        password = "2431",
        database = database,
        port = 3306,
        connectionPool = connectionPool
    );
    
    return newClient;
}

// Function to get connection pool statistics
public function getConnectionPoolInfo() returns sql:ConnectionPool {
    return sql:getGlobalConnectionPool();
}