# Chapter 1 Postgres notes

Postgres is tried and tested over decades of use and proven to
scale. It is a relational database - relational not because tables relate to each other, but
because they are built atop set theory mathematics (relational algebra).

You have to specify your schema up front when you create tables and so your data
is guaranteed to be consistent. This is a good thing because the applications you
build on top of postres can rely on these guarantees, however I could see it being
a disadvantage if the shape of your data is constantly evolving as you'd need to
constantly migrate your data and queries. This is in contrast to CouchDB which is
schemaless, where you write your views over heterogeneous docs.

Postgres also guarantees referential integrity. You can't add a row to a table that
has a non-existant reference in another table. On reading this I wondered what would
happen if you removed a row which is being used as a reference in a row in another
table - would postgres stop this? I assume so otherwise the guarantee over referential
integrity would only be valid at write time, which wouldn't be much use!

I spent a bit of time thinking about why referential integrity was a good thing,
and how you might try and get similar guarantees using a NoSQL database. The only
way I could think of would be to nest your documents, so the relationship between
parent and children is enforced. Obviously this doesn't work for many to many
relationships. In a NoSQL database like MongoDB I think this could also make querying
on children slower, as you would first have to retrieve all parents and flatten.
In CouchDB you could create a view over just the children (emitting a record for
each child in your map function) and so in theory it should be just as fast to query
as postgres, although the view would need to be updated on each insertion.

The chapter then moves on to demonstrating the different joins. I think this is
where the declarative nature of SQL comes in to its own. I noted that it is however
important to set indexes correctly to ensure any join statements are performant.

Interestingly when you create an index in postgres (or have one automatically
created by setting a primary key or unique (?) column) it stores it in a b-tree
just like Couch stores all of its data! So the interesting comparison here is that
in postgres you only get data stored in this efficient way when you specify an index,
and you have to remember to make sure these are specified every time you modify or
create a new query. Where as in Couch you are essentially *forced* to create these
indexes when you create your queries (in the format of mapreduce views).

At this point I got a little sidetracked refreshing my memory of how b-trees worked
and how they differ from binary trees. I learned a new bit of lingo for describing
a b-tree: a 2-3 order b-tree is one in which each internal node can have between
2 and 3 children. I also learned that no one actually knows what the 'b' stood for,
if it ever stood for anything at all!

Also read that you can use an alternative hash index in postgres, but this doesn't
allow range queries unlike a b-tree, which makes sense when you visualise the data
structures. I assume that a hash will be faster in the instances where you only
care about querying on a single unique key.
