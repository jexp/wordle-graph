CREATE CONSTRAINT word_name IF NOT EXISTS ON (w:Word) ASSERT w.name IS UNIQUE;

CREATE CONSTRAINT cap_idx_char IF NOT EXISTS FOR (cap:CharAtPos) REQUIRE (cap.idx, cap.char) IS NODE KEY;

LOAD CSV FROM 
"https://gist.githubusercontent.com/jexp/b1882301adb95a8015d6c29d3e24e341/raw/6fe6ac31b9ed46900451e17b5215e9088ec09a6e/wordle.csv" as row 
MERGE (w:Word {name:row[0]});

:auto MATCH (w:Word) 
CALL { WITH w 
WITH w, split(w.name,"") AS chars
MERGE (start:CharAtPos {idx:0, char:chars[0]})
MERGE (w)-[:STARTS]->(start)
MERGE (w)-[:HAS]->(start)
WITH *
UNWIND range(1,size(chars)-1) AS idx
MERGE (next:CharAtPos {idx:idx, char:chars[idx]})
MERGE (w)-[:HAS]->(next)
WITH *
MATCH (prev:CharAtPos {idx:idx-1, char:chars[idx-1]})
MERGE (prev)-[:NEXT]->(next)
} IN TRANSACTIONS OF 1000 ROWS;

MATCH p=(n:Word {name:"crash"})--() RETURN p LIMIT 25;

MATCH (c1:CharAtPos {idx:0, char:'c'}), 
      (c5:CharAtPos {idx:4, char:'h'}),
      (c:CharAtPos {char:'a'})
match (w:Word)-[:HAS]->(c1),
      (w)-[:HAS]->(c5),
      (w)-[:HAS]->(c)
return w.name;

/*
╒════════╕
│"w.name"│
╞════════╡
│"clach" │
├────────┤
│"clash" │
├────────┤
│"caneh" │
├────────┤
│"coach" │
├────────┤
│"catch" │
├────────┤
│"crash" │
└────────┘
*/

// more detailed with exclusions and wrong position

match (c1:CharAtPos {idx:0, char:'c'}), // correct 
      (c2:CharAtPos {idx:1, char:'a'}), // wrong pos     
      (c3:CharAtPos {char:'l'}),  // incorrect    
      (c4:CharAtPos {char:'i'}),  // incorrect
      (c5:CharAtPos {idx:4, char:'h'}), // correct
      (c:CharAtPos {char:'a'})
match (w:Word)-[h1:HAS]->(c1),
      (w)-[h2:HAS]->(c5), (w)-[h3:HAS]->(c)
WHERE not exists { (w)-[:HAS]->(c2) } and not exists { (w)-[:HAS]->(c3) } and not exists { (w)-[:HAS]->(c4) }
return *