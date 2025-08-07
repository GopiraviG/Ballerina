import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client mysqlClient = check new ("localhost", "root", "2431", "ballerina", 3306);
