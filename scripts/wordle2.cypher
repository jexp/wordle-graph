// Alternative model
// index in rel-type

MATCH (w:Word) 
WITH w, split(w.name,"") AS chars
MERGE (c0:Char {char:chars[0]})
MERGE (w)-[:POS0]->(c0)
MERGE (c1:Char {char:chars[1]})
MERGE (w)-[:POS1]->(c1)
MERGE (c2:Char {char:chars[2]})
MERGE (w)-[:POS2]->(c2)
MERGE (c3:Char {char:chars[3]})
MERGE (w)-[:POS3]->(c3)
MERGE (c4:Char {char:chars[4]})
MERGE (w)-[:POS4]->(c4);


MATCH p=(n:Word {name:"crash"})--(:Char) RETURN p LIMIT 25;

MATCH (c:Char {char:'c'}), 
      (h:Char {char:'h'}),
      (a:Char {char:'a'})
MATCH (wordle:Word)-[:POS0]->(c),
      (wordle)-[:POS4]->(h),
      (wordle)-->(a)
RETURN wordle.name;

MATCH (c:Char {char:'c'}), 
      (h:Char {char:'h'}),
      (a:Char {char:'a'})
MATCH (wordle:Word)-[p0:POS0]->(c),
      (wordle)-[p4:POS4]->(h),
      (wordle)-[px]->(a)
RETURN *;

// more detailed with exclusions and wrong position

MATCH (c:Char {char:'c'}), 
      (h:Char {char:'h'}),
      (a:Char {char:'a'})
MATCH (wordle:Word)-[p0:POS0]->(c),
      (wordle)-[p4:POS4]->(h),
      (wordle)-[px]->(a)
WHERE not exists { (wordle)-[:POS1]->(a) } 
  AND not exists { (wordle)-[:POS2]->(:Char {char:'l'}) } 
  AND not exists { (wordle)-[:POS3]->(:Char {char:'i'}) }
RETURN *;
