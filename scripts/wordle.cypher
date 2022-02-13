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
return *;


WITH [{char:'c',match:true},{char:'a'},{char:'l',match:false},{char:'i',match:false},{char:'h',match:true}] as input
MATCH (w:Word)
WHERE all(idx in range(0,size(input)-1) WHERE
   case input[idx].match
   when true then exists { (w)-[:HAS]->(:CharAtPos {idx:idx, char:char}) }
   when false then not exists { (w)-[:HAS]->(:CharAtPos {char:char}) }
   else exists { (w)-[:HAS]->(:CharAtPos {char:char}) }
   end
)
RETURN w.word;

WITH [{char:'c',match:true},{char:'a'},{char:'l',match:false},{char:'i',match:false},{char:'h',match:true}] as input
MATCH (w:Word)
CALL { WITH input, w
      UNWIND range(0,size(input)-1) as idx
      WITH size(input) as total, idx, w, input[idx].match as m, input[idx].char as char
      WHERE (m AND exists { (w)-[:HAS]->(:CharAtPos {idx:idx, char:char}) })
      OR (m = false AND NOT exists { (w)-[:HAS]->(:CharAtPos {char:char}) })
      OR (m IS NULL AND exists { (w)-[:HAS]->(:CharAtPos {char:char}) })
      WITH total, count(*) as count WHERE count = total
      RETURN true as found
}
RETURN w.name;


WITH [{char:'c',match:true},{char:'a'},{char:'l',match:false},{char:'i',match:false},{char:'h',match:true}] as input
MATCH (w:Word)
WHERE all(idx in range(0,size(input)-1) WHERE
   case input[idx].match
   when true then exists { (w)-[:HAS]->(:CharAtPos {idx:idx, char:char}) }
   when false then not exists { (w)-[:HAS]->(:CharAtPos {char:char}) }
   else exists { (w)-[:HAS]->(:CharAtPos {char:char}) }
   end
)
RETURN w.word;


WITH 'C a l! i! H' AS input
WITH split(input,' ') as parts
UNWIND range(0,size(parts)-1) as idx
WITH idx, 
     toLower(substring(parts[idx],0,1)) as char, 
     parts[idx] ends with '!' as exclude,
     toUpper(substring(parts[idx],0,1)) = substring(parts[idx],0,1) as correct

MATCH (w:Word)
WHERE correct AND exists { (w)-[:HAS]->(c:CharAtPos {idx:idx, char:char}) }
OR NOT correct AND exclude and NOT exists { (w)-[:HAS]->(c:CharAtPos {char:char}) }
OR NOT correct AND NOT exclude AND exists { (w)-[:HAS]->(c:CharAtPos {char:char}) }

RETURN w.name;


Words with duplicate letters

MATCH (c1:CharAtPos)<--(w)-->(c2:CharAtPos) 

WHERE c1.char = c2.char and c1<>c2
RETURN count(distinct w)

// 4650

match path = (:Word {name:"diver"})-->()
return path



match (w:Word) with w skip $word limit 1
with split($guess,'') as guessed, split(w.name,'') as letters, w.name as name
return reduce(res="", idx in range(0,size(letters)-1) | 
res + case 
when guessed[idx] = letters[idx] then '🟩' 
when name contains guessed[idx] then '🟨'
else '⬜' end) as res
