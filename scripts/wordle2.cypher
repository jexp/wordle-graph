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


// frequencies

MATCH (c:Char)
RETURN c.char, size((c)<--()) as deg
ORDER BY deg DESC;

/*
╒════════╤═════╕
│"c.char"│"deg"│
╞════════╪═════╡
│"s"     │6665 │
├────────┼─────┤
│"e"     │6662 │
├────────┼─────┤
│"a"     │5990 │
├────────┼─────┤
│"o"     │4438 │
├────────┼─────┤
│"r"     │4158 │
├────────┼─────┤
│"i"     │3759 │
├────────┼─────┤
│"l"     │3371 │
├────────┼─────┤
│"t"     │3295 │
├────────┼─────┤
│"n"     │2952 │
├────────┼─────┤
│"u"     │2511 │
├────────┼─────┤
│"d"     │2453 │
├────────┼─────┤
│"y"     │2074 │
├────────┼─────┤
│"c"     │2028 │
├────────┼─────┤
│"p"     │2019 │
├────────┼─────┤
│"m"     │1976 │
├────────┼─────┤
│"h"     │1760 │
├────────┼─────┤
│"g"     │1644 │
├────────┼─────┤
│"b"     │1627 │
├────────┼─────┤
│"k"     │1505 │
├────────┼─────┤
│"f"     │1115 │
├────────┼─────┤
│"w"     │1039 │
├────────┼─────┤
│"v"     │694  │
├────────┼─────┤
│"z"     │434  │
├────────┼─────┤
│"j"     │291  │
├────────┼─────┤
│"x"     │288  │
├────────┼─────┤
│"q"     │112  │
└────────┴─────┘
*/


MATCH (w:Word)
MATCH (w)-->(c:Char)
RETURN w.word, sum(size((c)<--())) as total
ORDER BY total DESC LIMIT 10;

// unqiue chars
MATCH (w:Word)
MATCH (w)-->(c:Char)
RETURN w.word, sum(size((c)<--())) as total, count(distinct c) = 5 as uniques
ORDER BY uniques DESC, total DESC LIMIT 10;


// misses occurences
MATCH (c1:CharAtPos)-[:NEXT]->(c2:CharAtPos)
RETURN c1.char, c2.char, count(*) as freq
ORDER BY freq DESC limit 20;


// with occurences of double letters

MATCH (c1:CharAtPos)-[r:NEXT]->(c2:CharAtPos) 

WHERE c1.char = c2.char
RETURN c1.char, c2.char, sum(size( (c1)<--()) + size( (c2)<--())) as follow
ORDER BY follow DESC LIMIT 20;

╒═════════╤═════════╤════════╕
│"c1.char"│"c2.char"│"follow"│
╞═════════╪═════════╪════════╡
│"e"      │"e"      │11970   │
├─────────┼─────────┼────────┤
│"a"      │"a"      │9668    │
├─────────┼─────────┼────────┤
│"o"      │"o"      │8660    │
├─────────┼─────────┼────────┤
│"l"      │"l"      │6399    │
├─────────┼─────────┼────────┤
│"s"      │"s"      │6248    │


MATCH (c1:CharAtPos)-[r:NEXT]->(c2:CharAtPos) 
RETURN c1.char, c2.char, sum(size( (c1)<--()) + size( (c2)<--())) as follow
ORDER BY follow DESC LIMIT 20

╒═════════╤═════════╤════════╕
│"c1.char"│"c2.char"│"follow"│
╞═════════╪═════════╪════════╡
│"a"      │"e"      │12576   │
├─────────┼─────────┼────────┤
│"e"      │"e"      │11970   │
├─────────┼─────────┼────────┤
│"a"      │"s"      │11287   │
├─────────┼─────────┼────────┤
│"e"      │"a"      │10867   │
├─────────┼─────────┼────────┤
│"s"      │"e"      │10770   │
├─────────┼─────────┼────────┤
│"e"      │"s"      │10681   │


Lest likely to follow each other (ASC)

╒═════════╤═════════╤════════╕
│"c1.char"│"c2.char"│"follow"│
╞═════════╪═════════╪════════╡
│"j"      │"j"      │92      │
├─────────┼─────────┼────────┤
│"b"      │"j"      │142     │
├─────────┼─────────┼────────┤
│"v"      │"h"      │196     │
├─────────┼─────────┼────────┤
│"x"      │"f"      │250     │
├─────────┼─────────┼────────┤
│"q"      │"f"      │265     │
├─────────┼─────────┼────────┤
│"q"      │"h"      │269     │




// char frequency unique set of letters
match (w:Word)-->(c:Char)
WITH w.name as word, sum(size((c)<--())) as total, count(distinct c) = 5 as unique
WHERE unique 
WITH * ORDER BY total DESC LIMIT 1000
RETURN apoc.coll.sort(split(word,'')) as chars, max(total), collect(word)[0];



// follow frequency
CALL {
MATCH (c1:Char)<-[:POS0]-(w)-[:POS1]->(c2:Char)
RETURN c1.char as char1, c2.char as char2, count(*) as freq
UNION ALL
MATCH (c1:Char)<-[:POS1]-(w)-[:POS2]->(c2:Char)
RETURN c1.char as char1, c2.char as char2, count(*) as freq
UNION ALL
MATCH (c1:Char)<-[:POS2]-(w)-[:POS3]->(c2:Char)
RETURN c1.char as char1, c2.char as char2, count(*) as freq
UNION ALL
MATCH (c1:Char)<-[:POS3]-(w)-[:POS4]->(c2:Char)
RETURN c1.char as char1, c2.char as char2, count(*) as freq
}
RETURN char1, char2, sum(freq) as freq
ORDER BY freq DESC LIMIT 20;

// Solver


// first and last match
match (c0:Char {char:'c'})<-[:POS0]-(w)-[:POS4]->(c4:Char {char:'h'})
RETURN w.name


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



// auto solver
// needs idx on rel-type ala
match ()-[r:POS4]->() set r.idx=4;


// C a l! i! H
WITH [{char:'l',match:true},{char:'a'},{char:'t',match:true},{char:'e',match:true},{char:'r',match:false}] as input
MATCH (w:Word)
CALL {
    WITH w, input
    UNWIND range(0,size(input)-1) as idx
    WITH size(input) as total, idx, w, input[idx].match as m, input[idx].char as char
    WHERE (m AND exists { (w)-[{idx:idx}]->(:Char {char:char}) })
      OR (m = false AND NOT exists { (w)-->(:Char {char:char}) })
      OR (m IS NULL AND exists { (w)-->(:Char {char:char}) })
    WITH total, count(*) as count WHERE count = total
    RETURN true AS found
}
RETURN w.name


// ClotH
match (c0:Char {char:'c'})<-[:POS0]-(w)-[:POS4]->(c4:Char {char:'h'}),
(w)-[:POS1]->(c1:Char {char:'r'}),(w)-[:POS3]->(c3:Char {char:'s'})
where not exists { (w)-->(:Char {char:'l'})}
AND not exists { (w)-->(:Char {char:'o'})}
AND not exists { (w)-->(:Char {char:'t'})}
AND not exists { (w)-->(:Char {char:'u'})}
RETURN w.name

// crash

