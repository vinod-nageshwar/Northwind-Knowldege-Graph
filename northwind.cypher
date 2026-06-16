//Drop and Create Database
//DROP DATABASE northwind;
//CREATE DATABASE northwind;

//Creating Constraints
CREATE CONSTRAINT customer_customerId_companyName IF NOT EXISTS FOR (n:Customer) REQUIRE (n.customerId) IS UNIQUE;
CREATE CONSTRAINT contact_name_title IF NOT EXISTS FOR (n:Contact) REQUIRE (n.name,n.title) IS UNIQUE;
CREATE CONSTRAINT city_name IF NOT EXISTS FOR (n:City) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT country_name IF NOT EXISTS FOR (n:Country) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT category_categoryId IF NOT EXISTS FOR (n:Category) REQUIRE n.categoryId IS UNIQUE;
CREATE CONSTRAINT ship_name IF NOT EXISTS FOR (n:Ship) REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT employee_employeeId IF NOT EXISTS FOR (n:Employee) REQUIRE n.employeeId IS UNIQUE;
CREATE CONSTRAINT product_productId IF NOT EXISTS FOR (n:Product) REQUIRE n.productId IS UNIQUE;
CREATE CONSTRAINT supplier_supplierId IF NOT EXISTS FOR (n:Supplier) REQUIRE (n.supplierId) IS UNIQUE;
CREATE CONSTRAINT shipper_shipperId IF NOT EXISTS FOR (n:Shipper) REQUIRE (n.shipperId) IS UNIQUE;
CREATE CONSTRAINT order_orderId_orderDate IF NOT EXISTS FOR (n:Order) REQUIRE (n.orderId,n.orderDate) IS UNIQUE;

//Creating Customer, Contact, City & Country Nodes
//Creating Customer -> Contact Relationships
//Creating Customer -> City Relationships
//Creating City -> Country Relationships
CALL apoc.periodic.iterate(
  "CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=',
'select * from customers')
YIELD row",
  "MERGE (cust:Customer{customerId:row.customer_id})
SET cust.companyName = trim(row.company_name),
cust.address = trim(row.address),
cust.zipCode = trim(row.post_code),
cust.phone = coalesce(row.phone,'NA'),
cust.fax = coalesce(row.fax,'NA')
MERGE (ct:Contact{name:trim(row.contact_name),title:trim(row.contact_title)})
MERGE (cust)-[:POINT_OF_CONTACT]->(ct)
MERGE (cy:City{name:trim(row.city)})
MERGE (cust)-[:LOCATED_IN]->(cy)
MERGE (cn:Country{name:row.country})
MERGE (cy)-[:IS_IN]->(cn)
",
  {batchSize: 1000, iterateList: true, parallel: false});
  
//Creating Supplier, Contact, City & Country Nodes
//Creating Supplier -> Contact Relationships
//Creating Supplier -> City Relationships
//Creating City -> Country Relationships
CALL apoc.periodic.iterate(
  "CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=',
'SELECT * FROM suppliers')
YIELD row",
  "MERGE (sup:Supplier{supplierId:row.supplier_id})
SET sup.companyName = trim(row.company_name),
sup.address = trim(row.address),
sup.zipCode = trim(row.post_code),
sup.phone = coalesce(row.phone,'NA'),
sup.fax = coalesce(row.fax,'NA')
MERGE (ct:Contact{name:trim(row.contact_name),title:trim(row.contact_title)})
MERGE (sup)-[:POINT_OF_CONTACT]->(ct)
MERGE (cy:City{name:trim(row.city)})
MERGE (sup)-[:LOCATED_IN]->(cy)
MERGE (cn:Country{name:row.country})
MERGE (cy)-[:IS_IN]->(cn)
",
  {batchSize: 1000, iterateList: true, parallel: false});
  
//Creating Employee, City & Country Nodes
//Creating Emplpoyee -> City relationships
//Creating City -> Country relationships
CALL apoc.periodic.iterate(
  "CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=',
'select * from employees')
YIELD row",
  "MERGE (emp:Employee{employeeId:row.employee_id})
SET emp.lastName = trim(row.last_name),
emp.firstName = trim(row.first_name),
emp.title = trim(row.title),
emp.birthDate = date(row.birth_date),
emp.hireDate = date(row.hire_date),
emp.address = trim(row.address),
emp.notes = trim(row.notes)
MERGE (cy:City{name:trim(row.city)})
MERGE (emp)-[:LOCATED_IN]->(cy)
MERGE (cn:Country{name:row.country})
MERGE (cy)-[:IS_IN]->(cn)
",
  {batchSize: 1000, iterateList: true, parallel: false});  
  
//Creating Product, Category Nodes
//Creating Product -> Category Relationships
//Creating Supplier -> Product Relationships
CALL apoc.periodic.iterate(
  "CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=',
'SELECT * FROM products prd
JOIN categories cat
ON prd.category_id=cat.category_id')
YIELD row",
"MERGE (prd:Product{productId:row.product_id})
SET prd.name = trim(row.product_name),
prd.quantityPerUnit = trim(row.quantity_per_unit),
prd.unitPrice = toFloat(row.unit_price),
prd.discontinued = toInteger(row.discontinued)
MERGE (cat:Category{categoryId:row.category_id})
SET cat.name = trim(row.category_name)
MERGE (prd)-[:BELONGS_TO]->(cat)
WITH prd,row
MATCH (sup:Supplier{supplierId:row.supplier_id})
MERGE (sup)-[:SUPPLIES]->(prd)
",
{batchSize: 1000, iterateList: true, parallel: false}
);
  
//Creating Shipper Nodes
CALL apoc.periodic.iterate(
  "CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=',
'SELECT * FROM shippers')
YIELD row",
  "MERGE (shp:Shipper{shipperId:row.shipper_id})
SET shp.companyName = trim(row.company_name),
shp.phone = trim(row.phone)
",
  {batchSize: 1000, iterateList: true, parallel: false});  

//Creating Order, Ship  Nodes
//Creating Ship -> Shipper relationships
//Creating Order -> Product relationships
//Creating Customer -> Order relationships
CALL apoc.periodic.iterate(
  "CALL apoc.load.jdbc('jdbc:postgresql://localhost:5432/northwind?user=postgres&password=',
'SELECT * FROM orders ord
JOIN order_details orddet
ON ord.order_id=orddet.order_id')
YIELD row",
"MERGE (ord:Order{orderId:row.order_id,orderDate:date(row.order_date)})
SET ord.requiredDate = date(row.required_date),
ord.shippedDate = date(row.shipped_date)
MERGE (ship:Ship{name:row.ship_name})
WITH ord,ship,row
MATCH (shpr:Shipper{shipperId:row.ship_via})
MERGE (ship)-[:OWNED_BY]->(shpr)
MERGE (ord)-[:SHIPPED_IN{freight:toFloat(row.freight)}]->(ship)
WITH ord,row
MATCH (prd:Product{productId:row.product_id})
MERGE (ord)-[:CONTAINS{quantity:row.quantity,discount:row.discount}]->(prd)
WITH ord,row
MATCH (cust:Customer{customerId:row.customer_id})
MERGE (cust)-[:PLACED]->(ord)
WITH ord,row
MATCH (emp:Employee{employeeId:row.employee_id})
MERGE (emp)-[:PROCESSED]->(ord)
",
{batchSize: 1000, iterateList: true, parallel: false}
);
