CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=System7480$',
'select count(*) from customers')
YIELD row
MATCH (cust:Customer) WITH labels(cust)[0] as Node, COUNT(cust) as Neo4j_Count,row.count as Postgres_Count
RETURN Node,Neo4j_Count,Postgres_Count;

CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=System7480$',
'select count(*) from employees')
YIELD row
MATCH (n:Employee) WITH labels(n)[0] as Node, COUNT(n) as Neo4j_Count,row.count as Postgres_Count
RETURN Node,Neo4j_Count,Postgres_Count;

CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=System7480$',
'select count(*) from suppliers')
YIELD row
MATCH (n:Supplier) WITH labels(n)[0] as Node, COUNT(n) as Neo4j_Count,row.count as Postgres_Count
RETURN Node,Neo4j_Count,Postgres_Count;

CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=System7480$',
'select count(*) from orders')
YIELD row
MATCH (n:Order) WITH labels(n)[0] as Node, COUNT(n) as Neo4j_Count,row.count as Postgres_Count
RETURN Node,Neo4j_Count,Postgres_Count;

CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=System7480$',
'select count(*) from products')
YIELD row
MATCH (n:Product) WITH labels(n)[0] as Node, COUNT(n) as Neo4j_Count,row.count as Postgres_Count
RETURN Node,Neo4j_Count,Postgres_Count;

CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=System7480$',
'SELECT supplier_id,count(supplier_id) as cnt FROM products group by supplier_id order by supplier_id;')
YIELD row
MATCH (n:Supplier)-[r:SUPPLIES]->(m:Product) WHERE n.supplierId=row.supplier_id 
WITH n.supplierId as Neo4j_Supplier,row.supplier_id as Postgres_Supplier,COUNT(r) as Neo4j_Count,row.cnt as Postgres_Count
RETURN DISTINCT Neo4j_Supplier,Postgres_Supplier,Neo4j_Count,Postgres_Count;