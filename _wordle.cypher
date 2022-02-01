create constraint on (w:Word) assert w.name is unique;

// create constraint on (c:CharAtPos) assert node key (idx, char);

load csv from 
"https://gist.githubusercontent.com/jexp/b1882301adb95a8015d6c29d3e24e341/raw/6fe6ac31b9ed46900451e17b5215e9088ec09a6e/wordle.csv" as row 
merge (w:Word {name:row[0]});

match (w:Word) 
call { with w 
with w, split(w.name,"") as chars
merge (start:CharAtPos {idx:0, char:chars[0]})
merge (w)-[:STARTS]->(start)
merge (w)-[:HAS]->(start)
with *
unwind range(1,size(chars)-1) as idx
merge (next:CharAtPos {idx:idx, char:chars[idx]})
merge (w)-[:HAS]->(next)
with *
match (prev:CharAtPos {idx:idx-1, char:chars[idx-1]})
merge (prev)-[:NEXT]->(next)
} in transactions of 1000 rows;

MATCH p=(n:Word {name:"crash"})--() RETURN p LIMIT 25;