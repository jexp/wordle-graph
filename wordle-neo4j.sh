#!/bin/bash
# 3332
word=${1-$(( $RANDOM % 12972 ))}
# echo $word
rounds=${2-6}
count=1
res='     '
while [[ "$res" != "XXXXX" || count < $rounds ]]; do
printf "Guess $count: "
read guess
res=$(curl https://demo.neo4jlabs.com:7473/db/wordle/tx/commit \
 -s -X POST -d '{"statements":[{"statement":"match (w:Word) with w skip $word limit 1 with split($guess,\"\") as guessed, split(w.name,\"\") as letters, w.name as name return reduce(res=\"\", idx in range(0,size(letters)-1) | res + case when guessed[idx] = letters[idx] then \"X\" when name contains guessed[idx] then \"x\" else \"_\" end) as res", "parameters":{"word":'$word',"guess":"'$guess'"}}]}' -u wordle:wordle -H 'accept:application/json; charset=UTF-8' -H 'content-type:application/json; charset=UTF-8' | cut -b49-53)
echo $res | tr 'Xx_' '🟩🟨⬜'
count=$[$count+1]
done

echo Guessed \"$guess\" resulting in $(echo $res | tr 'Xx_' '🟩🟨⬜') in $[$count-1] rounds.

# dbms demo.neo4jlabs.com
# user/password/database: worlde
# statement
# params: word: offset, guess: text
<< EOF
match (w:Word) 
with w skip $word limit 1 
with split($guess,'') as guessed, split(w.name,'') as letters, w.name as name 
return reduce(res='', idx in range(0,size(letters)-1) | res + 
  case when guessed[idx] = letters[idx] then '🟩' 
  when name contains guessed[idx] then '🟨'
  else '⬜' end) as res
EOF