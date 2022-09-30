-- Cria um database de teste
CREATE DATABASE TESTE_CDC
GO
USE TESTE_CDC
GO

-- Cria tabela de exemplo
CREATE TABLE dbo.Cliente(id INT IDENTITY PRIMARY KEY, nome VARCHAR(100))
GO

-- Habilita o CDC no database
EXEC sys.sp_cdc_enable_db
GO

-- Habilita o CDC na tabela Cliente
EXEC sys.sp_cdc_enable_table  
@source_schema = N'dbo',  
@source_name   = N'Cliente',  
@role_name     = NULL,  
@filegroup_name = NULL,
@supports_net_changes = 0
GO

-- Checa se Datatbase e Tabela estãocom CDC habilitados
select is_cdc_enabled, * from SYS.databases
select is_tracked_by_cdc, * from sys.tables

-- Insere dados e modifica
insert into Cliente values ('Cliente 1')
update Cliente set nome = 'Cliente 1 Alterado' where id = 1

-- Consulta na tabela CDC criada automaticamente para armazenar as alterações feitas na tabela Cliente
select * from cdc.dbo_Cliente_CT where id = 1