//Creates OrderSummary Virtual Nodes
//Creates ORDERS_PLACED Virtual Relation
MATCH (cust:Customer)-[r:PLACED]->(ord:Order)
WITH cust, count(r) AS orderCount ORDER BY orderCount DESC LIMIT 5
CALL apoc.create.vNode(['OrderSummary'], {totalOrders: orderCount}) YIELD node AS summaryNode
RETURN cust, 
       summaryNode, 
       apoc.create.vRelationship(cust, 'ORDERS_PLACED',{},summaryNode) AS vR

//Creates OrderTotal Virtual Nodes
//Creates ORDERS_PLACED Virtual Relation
MATCH (cust:Customer)-[r:PLACED]->(ord:Order)
WITH count(r) as totalOrder
CALL apoc.create.vNode(['OrderTotal'], {totalOrders: totalOrder}) YIELD node AS totalNode
MATCH (cust1:Customer)-[r1:PLACED]->(ord1:Order)
WITH cust1, count(r1) AS orderCount,totalNode  ORDER BY orderCount DESC LIMIT 10
RETURN cust1,
       totalNode, 
      apoc.create.vRelationship(totalNode, 'ORDERS_PLACED',{cnt:orderCount},cust1) AS vR1
	   	   
//Creates OrderTotal & OrderSummary Virtual Nodes
//Creates ORDERS_PLACED_BY Virtual Relation
//Creates NO_OF_ORDERS Virtual Relation
MATCH (cust:Customer)-[r:PLACED]->(ord:Order)
WITH count(r) as totalOrder
CALL apoc.create.vNode(['OrderTotal'], {totalOrders: totalOrder}) YIELD node AS totalNode
MATCH (cust1:Customer)-[r1:PLACED]->(ord1:Order)
WITH cust1, count(r1) AS orderCount,totalNode  ORDER BY orderCount DESC LIMIT 10
CALL apoc.create.vNode(['OrderSummary'], {totalOrders: orderCount}) YIELD node AS summaryNode
RETURN cust1,
       totalNode, 
       summaryNode,
       apoc.create.vRelationship(totalNode, 'ORDERS_PLACED_BY',{},cust1) AS vR1,
       apoc.create.vRelationship(cust1, 'NO_OF_ORDERS',{},summaryNode) AS vR2
	   
	   
	   