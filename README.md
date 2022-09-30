
# Poc SqlServer CDC (Change Data Capture)
Exemplo de uso de SqlServer com Change Data Capture (CDC) habilitado.

Basicamente o CDC é um serviço que grava todo o histórico de alterações de uma tabela em outra tabela de forma transparente para a aplicação.

Para mais informações sobre o CDC: 
https://learn.microsoft.com/en-us/sql/relational-databases/track-changes/about-change-data-capture-sql-server?view=sql-server-ver16


## Docker Compose

Arquivo em `\dockercompose\sql-server-compose.yml`.

```yaml
services:
  sqlserver_local:
    image: mcr.microsoft.com/mssql/server:2019-latest
    environment:
      SA_PASSWORD: "SqlServer2019!"
      ACCEPT_EULA: "Y"
      MSSQL_PID: "Developer"
      MSSQL_AGENT_ENABLED: "True"
    ports:
      - "1433:1433"
```

**Importante:** O container deve subir com a variável `MSSQL_AGENT_ENABLED: "True"`, pois é o Agent do SqlServer que faz o trabalho de inserir as alterações nas tabelas do CDC. 

## Habilitando o CDC 

Arquivo em `\scripts\testes-cdc.sql`.
 ```sql
 -- Cria um database de teste
CREATE  DATABASE TESTE_CDC
USE TESTE_CDC

-- Cria tabela de exemplo
CREATE  TABLE dbo.Cliente(id INT  IDENTITY  PRIMARY  KEY, nome VARCHAR(100))

-- Habilita o CDC no database
EXEC sys.sp_cdc_enable_db
GO

-- Habilita o CDC na tabela Cliente
EXEC sys.sp_cdc_enable_table
            @source_schema =  N'dbo',
            @source_name =  N'Cliente',
            @role_name =  NULL,
            @filegroup_name =  NULL,
            @supports_net_changes =  0
GO

-- Checa se Datatbase e Tabela estãocom CDC habilitados
select is_cdc_enabled, *  from SYS.databases
select is_tracked_by_cdc, *  from sys.tables

-- Insere dados e modifica
insert  into Cliente values ('Clienbte 1')
update Cliente set nome =  'Cliente 1 Alterado'  where id =  1

-- Consulta na tabela CDC criada automaticamente para armazenar as alterações feitas na tabela Cliente
select  *  from cdc.dbo_Cliente_CT where id =  1
```

**OBS.:** Ao habilitar o CDC para uma tabela, o SqlServer gera uma tabela "clone" em `cdc.dbo_NOME-DA-TABELA_CT`. 
Exemplo: 
```
Tabela: dbo.Cliente
Tabela histórico: cdc.dbo_Cliente_CT.
```
