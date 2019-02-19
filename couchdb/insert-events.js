const nano = require('nano')('http://localhost:5984/');
const moment = require('moment');
const events = nano.db.use('events');

const docs = [
  {
    date: moment(),
    parent: "A",
    comp: "B",
    action: "add",
  },
  {
    date: moment().add(1, 'day'),
    parent: "A",
    comp: "B",
    action: "add",
  },
  {
    date: moment().add(2, 'day'),
    parent: "A",
    comp: "B",
    action: "delete",
  },
  {
    date: moment(),
    parent: "C",
    comp: "D",
    action: "add",
  },
  {
    date: moment().add(1, 'day'),
    parent: "C",
    comp: "D",
    action: "add",
  },
  {
    date: moment().add(2, 'day'),
    parent: "C",
    comp: "D",
    action: "delete",
  },
  {
    date: moment().add(3, 'day'),
    parent: "C",
    comp: "D",
    action: "add",
  },
];

const main = async () => {
  const info = await nano.db.list();
  console.log(info);
  await events.bulk({ docs });
};

main();
