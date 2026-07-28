/*
===============================================================================
Create Database and Schemas
===============================================================================
Script Purpose:
    This script initializes the 'Data_Warehouse' environment. It checks if the 
    database already exists; if so, it safely terminates active connections, 
    drops the existing database, and recreates it from scratch. 
    Finally, it establishes the core data layers by creating the 'bronze', 
    'silver', and 'gold' schemas.

WARNING:
    Running this script will permanently DROP the entire 'Data_Warehouse' 
    database and all its contained data. Ensure you have backups if needed 
    before execution.
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'Data_Warehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Data_Warehouse')
BEGIN
    ALTER DATABASE Data_Warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Data_Warehouse;
END;
GO

-- Create Database 'Data_Warehouse'
CREATE DATABASE Data_Warehouse;
GO

USE Data_Warehouse;
GO

-- Create Schemas for Medallion Architecture (Bronze, Silver, Gold)
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO